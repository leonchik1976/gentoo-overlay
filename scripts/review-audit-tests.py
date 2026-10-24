#!/usr/bin/env python3
"""Recreate private test dependencies and run the requested ebuild test matrix."""
import concurrent.futures,json,os,pathlib,platform,socket,subprocess,sys,threading
root=pathlib.Path(__file__).resolve().parents[1];out=root/'tools/upgrade-audit-20261024';results=[]; results_lock=threading.Lock()
def run(cp,v,t,phase,site=None):
 env=dict(os.environ);env.pop('PYTHON_GIL',None)
 if site:env['AUDIT_TEST_SITE']=str(site)
 cmd=['python3','scripts/run-audit-build.py',cp,v,t,phase];log=out/f'review-{cp.split("/")[1]}-{t}-{phase}.log'
 with log.open('w') as f:r=subprocess.run(cmd,cwd=root,env=env,stdout=f,stderr=subprocess.STDOUT)
 item=dict(command=cmd,exit=r.returncode,log=str(log.relative_to(out)),target=t,architecture={'x86_64':'amd64','aarch64':'arm64'}.get(platform.machine(),platform.machine()),host=socket.gethostname(),dependency_site=str(site) if site else None);
 with results_lock:
  results.append(item);(out/'review-test-results.json').write_text(json.dumps(results,indent=2)+'\n')
 print(item,flush=True);return r.returncode

def one(t):
 for pkg,v in [('hypothesis','6.170.9'),('pytest-asyncio','1.4.0')]:
  if run('dev-python/'+pkg,v,t,'compile'):return
 sites=[]
 for pkg,v in [('hypothesis','6.170.9'),('pytest-asyncio','1.4.0')]:
  found=list(pathlib.Path('/tmp/codex/dev-python',pkg+'-'+v).glob(t+'-*/portage/*/*/work/**/install/usr/lib/python*/site-packages'));assert len(found)==1,found;sites+=found
 # Link staged dependencies together via .pth, without altering installed packages.
 (sites[0]/'audit-other-dependency.pth').write_text(str(sites[1])+'\n')
 for pkg,v in [('jh2','5.0.15'),('qh3','2.0.4')]:run('dev-python/'+pkg,v,t,'test',sites[0])
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:list(pool.map(one,sys.argv[1:] or ['python3_12','python3_13','python3_14','python3_14t']))
