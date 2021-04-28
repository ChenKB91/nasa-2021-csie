import hashlib
from tqdm import tqdm
import json

meow = {}


for i in tqdm(range(2**24)):
    meow[hashlib.md5(f'{i}'.encode()).hexdigest()[0:8]] = i


with open('data.txt','w') as f:
    json.dump(meow,f)