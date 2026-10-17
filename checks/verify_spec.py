from pathlib import Path
import itertools, json, math, random, re
p=Path(__file__).resolve().parent.parent/'BALL_VS_SPACE_RESEARCH_AND_BUILD_SPEC.md'
text=p.read_text(encoding='utf-8')
heads=re.findall(r'^## (\d+)\. (.+)$',text,re.M)
assert [int(n) for n,_ in heads]==list(range(1,16))
assert len(re.findall(r'^```',text,re.M))%2==0
project=json.loads(re.search(r'```json\n(.*?)\n```',text,re.S).group(1))
assert project['tree']['$className']=='DataModel'
refs=set(re.findall(r'^\[([RCDT]\d+)\]:',text,re.M))
uses=set(re.findall(r'\[([RCDT]\d+)\](?!\()',text))
assert not uses-refs,uses-refs

def step(q,a,b,drain=False):
    if drain:q-=(q>0)-(q<0)
    return max(-3,min(3,q+a-b))
def owner(q):return 1 if q>0 else 2 if q<0 else 0
for q,a,b,d in itertools.product(range(-3,4),range(3),range(3),[False,True]):
    new=step(q,a,b,d)
    assert -3<=new<=3
    assert new==-step(-q,b,a,d)
    if a==b and not d:assert new==q
q=3; seq=[]
for _ in range(4):q=step(q,0,1);seq.append(q)
assert seq==[2,1,0,-1]
assert step(step(3,0,2),0,2)==-1
assert step(2,max([1,1]),1)==2
assert step(2,1,max([1,2]))==1

rng=random.Random(965105)
board=[0]*1024; counts=[1024,0,0]
for _ in range(1000):
    claims=[(rng.randrange(2),rng.randrange(1024),rng.randint(1,2)) for _ in range(300)]
    def masks(cs):
        out=[[0]*1024,[0]*1024]
        for team,i,s in cs:out[team][i]=max(out[team][i],s)
        return out
    a,b=masks(claims);rng.shuffle(claims);assert [a,b]==masks(claims)
    drains=set(rng.sample(range(1024),10))
    for i,q in enumerate(board):
        new=step(q,a[i],b[i],i in drains)
        counts[owner(q)]-=1;counts[owner(new)]+=1;board[i]=new
    assert counts==[sum(owner(q)==j for q in board) for j in range(3)]
    assert sum(counts)==1024
assert sum([600,384,40])==1024
assert [round(x*100/1024,1) for x in [600,384,40]]==[58.6,37.5,3.9]
assert sum([470,440,114])==1024
assert sum([511,510,3])==1024
assert 290+260-80==470
assert 12+8+2+30+3==55
assert 5+3*55+8+3*15==223

def ot(leads):
    last=None;held=0
    for n,margin in enumerate(leads,1):
        leader=1 if margin>=2 else 2 if margin<=-2 else None
        held=0 if leader is None else held+1 if last==leader else 1
        last=leader
        if held>=10:return leader,n
    return None,len(leads)
assert ot([4]*10)==(1,10)
assert ot([4]*9+[1]+[4]*9)==(None,19)
assert ot([0]*140+[-2]*10)==(2,150)
assert ot([0]*149+[4])==(None,150)

summary={'file':p.name,'words':len(text.split()),'bytes':p.stat().st_size,'sections':len(heads),'sources':len(refs),'checks':'PASS','influence_cases':126,'randomized_board_updates':1000,'randomized_contributors':300000,'note':'Design-contract checks in Python; not a Roblox or Luau build/playtest.'}
print(json.dumps(summary,indent=2))
(Path(__file__).parent/'spec-verification.json').write_text(json.dumps(summary,indent=2))
