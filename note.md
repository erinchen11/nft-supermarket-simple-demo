# Test Framework - Chai

## Syntax
```
describe('hooks', function() {
  // 測試區塊
  before(function() {
    // 在所有測試開始前會執行的程式碼區塊
  });

  after(function() {
    // 在所有測試結束後會執行的程式碼區塊
  });

  beforeEach(function() {
    // 在每個 Test Case 開始前執行的程式碼區塊
  });

  afterEach(function() {
    // 在每個 Test Case 結束後執行的程式碼區塊
  });

  // 撰寫個別 Test Case
  it('should ...', function() {
    // 執行 Test Case
  });
});
```

## Use IPFS to store user's file

see ipfs-http-client API, and Infura IPFS service

```
import { create } from 'ipfs-http-client'

// connect to the default API address http://localhost:5001
const client = create()

// connect to a different API
const client = create('http://127.0.0.1:5002')

// connect using a URL
const client = create(new URL('http://127.0.0.1:5002'))

// call Core API methods
const { cid } = await client.add('Hello world!')

```

### Implement Flow
[IPFS Doc](https://docs.ipfs.io/how-to/best-practices-for-nft-data/#types-of-ipfs-links-and-when-to-use-them "Title")


Use IPFS to store file, have two things to upload : the File, the information of File
1. upload file to IPFS with blockchain node API service, eg. infura.
after that will get CID of file, then concatenate the url of API service and CID
like : http://127.0.0.1:5002/{CID}, that the file's url

2. the information of file to upload to IPFS, must have the file's url
the information also call metadata, and JSON format, like this
```
{
  "name": "No time to explain!",
  "description": "I said there was no time to explain, and I stand by that.",
  "image": "ipfs://bafybeict2kq6gt4ikgulypt7h7nwj4hmfi2kevrqvnx2osibfulyy5x3hu/no-time-to-explain.jpeg"
}
```




