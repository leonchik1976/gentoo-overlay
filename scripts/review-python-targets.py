#!/usr/bin/env python3
"""Review target declarations without confusing inactive branches with blockers.
This is a direct-dependency target analysis, not a complete Portage solver.
"""
import json,pathlib,re
import portage
ROOT=pathlib.Path(__file__).resolve().parents[1]
OUT=ROOT/'tools/upgrade-audit-20261024'
inv=json.loads((OUT/'final-inventory.json').read_text())
raw=json.loads((OUT/'python-dependency-targets.json').read_text())
decisions=json.loads((OUT/'python-target-decisions.json').read_text())

def contexts(text):
 tokens=iter(text.split()); entries=[]
 def parse(context=()):
  for token in tokens:
   if token==')':return
   if token.endswith('?') or token in ('||','^^','??'):
    assert next(tokens)=='('
    parse(context+(token,))
   elif token=='(':parse(context)
   else:entries.append({'atom':token,'conditions':list(context)})
 parse();return entries

def atom_key(token):
 try:return str(portage.dep.Atom(token).without_use)
 except portage.exception.InvalidAtom:return token

def analyze(cp,target):
 m=dict(inv[cp]['metadata']); old=raw[cp][target]['dependencies']; lookup={x['atom']:x for x in old}
 regular=sorted(set(re.findall(r'python_(?:single_target|targets)_(python3_\d+)(?=\s|$)',m.get('IUSE',''))),key=lambda x:int(x.split('_')[1]))
 requested=int(re.search(r'_(\d+)',target)[1]); preceding=[x for x in regular if int(x.split('_')[1])<=requested]
 representative=(preceding or regular or ['python3_14'])[-1]
 # For a proposed single-target addition, evaluate an existing regular branch
 # as a hypothetical target branch; otherwise absent targets erase runtime deps.
 # Exact eclass/explicit python_gen_cond_dep ranges still require review.
 if 'python_single_target_'+target not in m.get('IUSE',''):
  for kind in ('RDEPEND','PDEPEND','DEPEND','BDEPEND','IDEPEND','REQUIRED_USE'):
   m[kind]=m.get(kind,'').replace('python_single_target_'+representative+'?', 'python_single_target_'+target+'?')
 if 'python_targets_'+target not in m.get('IUSE',''):
  for kind in ('RDEPEND','PDEPEND','DEPEND','BDEPEND','IDEPEND','REQUIRED_USE'):
   m[kind]=m.get(kind,'').replace('python_targets_'+representative+'?', 'python_targets_'+target+'?')
 for prefix in ('python_targets_','python_single_target_'):
  if prefix+target not in m.get('IUSE',''):
   m['REQUIRED_USE']=m.get('REQUIRED_USE','').replace(prefix+representative,prefix+target)
 rows=[]; allflags=set()
 for kind in ('RDEPEND','PDEPEND','DEPEND','BDEPEND','IDEPEND'):
  for entry in contexts(m.get(kind,'')):
   allflags.update(x.rstrip('?').lstrip('!') for x in entry['conditions'] if x.endswith('?'))
   key=atom_key(entry['atom']); evidence=lookup.get(key)
   if not evidence:continue
   entry.update(kind=kind,evidence=evidence)
   conditions=[x for x in entry['conditions'] if x.endswith('?') and not x.lstrip('!').startswith(('python_targets_','python_single_target_'))]
   entry['use_conditions']=conditions
   entry['role']=('documentation' if any(x in ('doc?','docs?') for x in conditions) else 'test' if 'test?' in conditions else 'conditional runtime' if kind in ('RDEPEND','PDEPEND') and conditions else 'mandatory runtime' if kind in ('RDEPEND','PDEPEND') else 'build')
   rows.append(entry)
 defaults={x[1:] for x in m.get('IUSE','').split() if x.startswith('+')} - {'test','doc','docs'}
 targetflags={'python_targets_'+target,'python_single_target_'+target}
 scenarios={'package defaults':defaults,'tests enabled':defaults|{'test'},'documentation enabled':defaults|{'doc','docs'}}
 for flag in sorted(allflags-{'test','doc','docs'}):
  if flag.startswith(('python_targets_','python_single_target_')):continue
  scenarios['USE='+('-' if flag in defaults else '')+flag]=(defaults-{flag}) if flag in defaults else defaults|{flag}
 def evaluate(node):
  if isinstance(node,list):
   if node and node[0]=='||':
    branches=[evaluate(x) for x in node[1:]]
    if any(not x for x in branches):return []
    return [{'alternative_group':branches}]
   if node and node[0] in ('^^','??'):
    return [{'unresolved_cardinality_group':node}]
   return [x for child in node for x in evaluate(child)]
  # Only dependencies actually requiring this implementation are relevant.
  atom=portage.dep.Atom(node)
  if not atom.use or not any('python_targets_' in x or 'python_single_target_' in x for x in atom.use.tokens):return []
  ev=lookup.get(str(atom.without_use))
  if ev and ev['status']=='declared':return []
  return [{'atom':str(atom.without_use),'blocker':ev['status'] if ev else 'not assessed in original matrix'}]
 result={}
 for label,flags in scenarios.items():
  kinds={}
  for kind in ('RDEPEND','PDEPEND','DEPEND','BDEPEND','IDEPEND'):
   reduced=portage.dep.use_reduce(m.get(kind,''),uselist=flags|targetflags,opconvert=True,eapi=m.get('EAPI','8'))
   kinds[kind]={'reduced_expression':reduced,'target_blockers':evaluate(reduced)}
  iuse={x.lstrip('+-') for x in m.get('IUSE','').split()}|targetflags
  try:
   required=portage.dep.check_required_use(m.get('REQUIRED_USE',''),flags|targetflags,iuse.__contains__,eapi=m.get('EAPI','8'))
   required_state={'satisfied':bool(required),'expression':m.get('REQUIRED_USE',''),'unsatisfied':required.tounicode() if not required else ''}
  except portage.exception.InvalidDependString as error:required_state={'satisfied':None,'error':str(error)}
  result[label]={'enabled_use':sorted(flags),'required_use':required_state,'dependencies':kinds}
 return {'target':target,'hypothetical_regular_branch':representative,'scope':'Direct target declarations only; package IUSE defaults, not host/profile USE. Optional/test/doc scenarios independent; REQUIRED_USE/profile solvability needs Portage validation. A declared direct dependency is not proof of its transitive chain.','atoms':rows,'scenarios':result}

# All three targets use the same scenario results, while declarations, upstream
# evidence, local validation and profile masks remain independent facts.
import shutil
import socket
profile_masks = set(portage.settings.usemask)
regular_additions = {'dev-python/botocore-stubs', 'dev-python/types-s3transfer',
                     'dev-python/pypandoc', 'dev-python/wassima'}

def make_decision(row, target, analysis):
 cp = row['package']
 prior = row.get('target_details', {}).get(target, {})
 if not prior:
  prior = (row.get('regular_details', {}) if target == 'python3_15'
           else row.get('free_threaded_details', {}).get(target, {}))
 old = prior.get('previous_decision', row[target])
 flags = {'python_targets_' + target, 'python_single_target_' + target}
 declared = bool(flags & {x.lstrip('+-') for x in inv[cp]['metadata'].get('IUSE', '').split()})
 blocks = analysis['scenarios']['package defaults']['dependencies']
 runtime = blocks['RDEPEND']['target_blockers'] + blocks['PDEPEND']['target_blockers']
 build = blocks['DEPEND']['target_blockers'] + blocks['BDEPEND']['target_blockers'] + blocks['IDEPEND']['target_blockers']
 verified = target != 'python3_15' and 'verified and added' in old.lower()
 if cp == 'dev-python/cfn-lint' and target in ('python3_15', 'python3_15t'):
  status = 'upstream incompatible'
  reason = 'Exact release Requires-Python >=3.10,<3.15 excludes the 3.15 language version, independently of GIL mode'
 elif verified:
  status = 'verified and added'
  reason = old.partition(':')[2].strip() or 'amd64 validation from previous audit; see recorded test results'
 elif declared or old.startswith('already'):
  status = 'already declared'
  reason = ('Previously authorized upstream-evidence-based regular 3.15 addition retained; no local build/test verification'
            if target == 'python3_15' and cp in regular_additions
            else 'Existing declaration; no new local validation implied')
 elif 'tree-sitter-grammar.eclass' in old:
  status = 'dependency blocked'
  reason = 'tree-sitter-grammar.eclass fixes PYTHON_COMPAT without this target; cannot override its contract locally'
 elif runtime or build:
  status = 'dependency blocked'
  reason = 'Missing Gentoo target declarations in active package-default ' + ('runtime' if runtime else 'build') + ' dependencies: ' + json.dumps(runtime or build)
 else:
  status = 'needs validation'
  reason = 'No active package-default direct target blocker; upstream version-specific evidence and complete local validation remain required'
 if cp == 'dev-python/ua-parser-builtins' and verified:
  reason = 'amd64 byte-compilation, packaged-file checks and staged import/GIL checks; no behavioral test suite'
 conditions = []
 for scenario in analysis['scenarios']:
  if scenario.startswith('USE='):
   affected = [x['atom'] for x in analysis['atoms'] if x['evidence']['status'] != 'declared' and any(scenario.removeprefix('USE=').lstrip('-') + '?' == c.lstrip('!') for c in x['use_conditions'])]
   if affected:
    conditions.append(scenario + ' affects ' + ', '.join(sorted(set(affected))))
 detail = dict(status=status, reason=reason, previous_decision=old,
               declared=declared, declaration_origin='evidence-based audit addition' if target == 'python3_15' and cp in regular_additions else 'existing ebuild metadata',
               upstream_evidence=row['evidence'],
               upstream_evidence_limit='Release/source references do not alone establish target-specific support; explicit regular 3.15 classifier/CI evidence is documented for the four retained additions',
               local_validation='recorded amd64 checks only' if verified else 'not locally build/test verified for this target',
               runtime_target_blockers=runtime, build_target_blockers=build,
               test_target_blockers=analysis['scenarios']['tests enabled']['dependencies']['BDEPEND']['target_blockers'],
               documentation_target_blockers=analysis['scenarios']['documentation enabled']['dependencies']['BDEPEND']['target_blockers'],
               conditional_blockers=conditions,
               interpreter=shutil.which(target.replace('python3_', 'python3.')),
               profile_mask_flags=sorted(flags & profile_masks),
               profile_mask_scope='Global profile USE masks read on ' + socket.gethostname() + '; package-specific overrides and complete solver state not evaluated')
 if not detail['interpreter']:
  reason += '; corresponding interpreter unavailable on ' + socket.gethostname()
 if detail['profile_mask_flags']:
  reason += '; target globally profile-masked on inspected host (no override performed)'
 if declared and (runtime or build):
  reason += '; declaration does not resolve active dependency target blockers: ' + json.dumps(runtime or build)
 required = analysis['scenarios']['package defaults']['required_use']
 if required['satisfied'] is False:
  detail['required_use_blocker'] = required['unsatisfied']
  reason += '; package-default USE also fails REQUIRED_USE: ' + required['unsatisfied']
 if detail['test_target_blockers']:
  reason += '; test-enabled dependency blockers: ' + json.dumps(detail['test_target_blockers'])
 if cp == 'dev-python/ua-parser-builtins' and verified:
  detail['validation_scope'] = 'Byte-compilation, packaged-file checks, staged import/GIL checks; no behavioral suite'
 detail['reason'] = reason
 return detail

refined = {}
for row in decisions:
 cp = row['package']
 refined[cp] = {}
 for target in ('python3_14t', 'python3_15', 'python3_15t'):
  analysis = analyze(cp, target)
  detail = make_decision(row, target, analysis)
  analysis['decision'] = detail
  refined[cp][target] = analysis
  row.setdefault('target_details', {})[target] = detail
  if target == 'python3_15':
   row['regular_details'] = detail
  else:
   row.setdefault('free_threaded_details', {})[target] = detail
  row[target] = detail['status'] + ': ' + detail['reason'] + (('; ' + '; '.join(detail['conditional_blockers'])) if detail['conditional_blockers'] else '')
(OUT/'python-dependency-analysis-refined.json').write_text(json.dumps(refined,indent=2)+'\n')
(OUT/'python-target-decisions.json').write_text(json.dumps(decisions,indent=2)+'\n')
p=OUT/'REPORT.md';text=p.read_text();start=text.index('| Package | python3_14t |');end=text.index('\ncfn-lint’s',start)
table='| Package | python3_14t | python3_15 | python3_15t | Evidence |\n|---|---|---|---|---|\n'
for row in decisions:
 cells=[f'`{row["package"]}`',row['python3_14t'],row['python3_15'],row['python3_15t'],row['evidence']]
 table+='| '+' | '.join(x.replace('|','&#124;').replace('\n',' ') for x in cells)+' |\n'
p.write_text(text[:start]+table+text[end:])
print('Reviewed',len(decisions),'packages independently for each target')
