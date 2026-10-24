#!/usr/bin/env python3
"""Supplemental Hypothesis controls after the Python 3.12 ebuild test run."""
import pathlib,subprocess,json,os
root=pathlib.Path(__file__).resolve().parents[1];out=root/'tools/upgrade-audit-20261024';build=next(pathlib.Path('/tmp/codex/dev-python/jh2-5.0.15').glob('python3_12-*/portage/dev-python/jh2-5.0.15/work/jh2-5.0.15'));site=next(build.parent.glob('*python3_12/install/usr/lib/python*/site-packages'));python=site.parents[2]/'bin/python3.12';scratch=build.parent/'patch-review';scratch.mkdir(exist_ok=True)
source=(build/'tests/test_invalid_headers.py').read_text(); decorator='    @settings(suppress_health_check=[HealthCheck.differing_executors])\n';assert source.count(decorator)==1
start=source.index('    def test_range_of_acceptable_outputs(');end=source.index('\n    @',start);method=source[start:end];assert 'self.' not in method
records=[]
for label,text in [('patched',source),('unpatched',source.replace(decorator,'')),('assertion-control',source.replace('        try:\n            assert headers == list(validation_function(', '        assert False, "audit deliberate failure control"\n        try:\n            assert headers == list(validation_function('))]:
 file=scratch/('test_'+label.replace('-','_')+'.py');file.write_text(text);cmd=[str(python),'-m','pytest','-q','-ra','--maxfail=1',str(file),'-k','test_range_of_acceptable_outputs'];env=dict(os.environ,PYTEST_DISABLE_PLUGIN_AUTOLOAD='1');env.pop('PYTHON_GIL',None)
 with (out/f'review-jh2-patch-{label}.log').open('w') as f:r=subprocess.run(cmd,cwd=scratch,env=env,stdout=f,stderr=subprocess.STDOUT)
 records.append(dict(label=label,command=cmd,exit=r.returncode,log=f'review-jh2-patch-{label}.log'))
(out/'review-jh2-patch-controls.json').write_text(json.dumps(records,indent=2)+'\n');print(records)
