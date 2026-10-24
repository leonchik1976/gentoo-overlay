#!/usr/bin/env python3
"""Record staged imports and unforced GIL state after isolated ebuild checks."""
import hashlib,json,os,pathlib,subprocess,sys
root=pathlib.Path(__file__).resolve().parents[1];cp,version,target=sys.argv[1:]
ebuild=root/cp/(cp.split('/')[1]+'-'+version+'.ebuild');digest=hashlib.sha256(ebuild.read_bytes())
for resource in sorted((ebuild.parent/'files').rglob('*')):
 if resource.is_file():digest.update(str(resource.relative_to(ebuild.parent)).encode());digest.update(resource.read_bytes())
workspace=pathlib.Path(os.environ.get('AUDIT_WORK_ROOT','/tmp/codex'))/(cp+'-'+version)/(target+'-'+digest.hexdigest()[:8]);workspace=pathlib.Path(os.environ.get('AUDIT_PROBE_WORKSPACE',workspace)).resolve();assert workspace.is_relative_to(pathlib.Path('/tmp/codex').resolve()) or workspace.is_relative_to(root);sites=list(workspace.glob('portage/*/*/work/**/install/usr/lib/python*/site-packages'));assert len(sites)==1,sites
site=sites[0];executable=site.parents[2]/'bin'/target.replace('python3_','python3.')
modules={'jh2':['jh2','jh2._hazmat','hypothesis','hypothesis._native'],'qh3':['qh3','qh3._hazmat','cryptography.hazmat.bindings._rust','pytest_asyncio'],'wassima':['wassima','ssl','_ssl','_hashlib'],'ua-parser-builtins':['ua_parser_builtins'],'ua-parser':['ua_parser','ua_parser_builtins','yaml._yaml']}[cp.split('/')[1]]
code='''import importlib,json,os,pathlib,sys,sysconfig
assert 'PYTHON_GIL' not in os.environ
assert 'gil' not in sys._xoptions, sys._xoptions
free=bool(sysconfig.get_config_var('Py_GIL_DISABLED'))
print(json.dumps({'interpreter':sys.version,'executable':sys.executable,'PYTHON_GIL':os.environ.get('PYTHON_GIL'),'xoptions':sys._xoptions,'gil_before':getattr(sys,'_is_gil_enabled',lambda:True)()}))
if free:assert not sys._is_gil_enabled()
for name in json.loads(sys.argv[1]):
 module=importlib.import_module(name);path=pathlib.Path(module.__file__).resolve()
 print(json.dumps({'module':name,'path':str(path),'gil_after':getattr(sys,'_is_gil_enabled',lambda:True)()}))
 if name.split('.')[0]==sys.argv[3]:assert path.is_relative_to(pathlib.Path(sys.argv[2]).resolve())
 if free:assert not sys._is_gil_enabled(),name
'''
env=dict(os.environ);env.pop('PYTHON_GIL',None);command=[str(executable),'-c',code,json.dumps(modules),str(site),modules[0].split('.')[0]]
r=subprocess.run(command,env=env,text=True,capture_output=True,cwd=workspace)
record=dict(package=cp,target=target,workspace=str(workspace),workspace_override=os.environ.get('AUDIT_PROBE_WORKSPACE'),current_ebuild_sha256=hashlib.sha256(ebuild.read_bytes()).hexdigest(),validation_scope='Staged same-version imports; workspace override reuses the prior compilation after validation-only ebuild changes',architecture={'x86_64':'amd64','aarch64':'arm64'}.get(__import__('platform').machine(),__import__('platform').machine()),host=__import__('socket').gethostname(),command=command,exit=r.returncode,stdout=r.stdout,stderr=r.stderr)
(root/'tools/upgrade-audit-20261024'/f'review-gil-{cp.split("/")[1]}-{target}.json').write_text(json.dumps(record,indent=2)+'\n');print(r.stdout,end='');print(r.stderr,end='',file=sys.stderr);raise SystemExit(r.returncode)
