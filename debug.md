Error - 1

Error: call revert exception (method="fetchMyNFTs()", errorArgs=null, errorName=null, errorSignature=null, reason=null, code=CALL_EXCEPTION, version=abi/

solution:
run step
    npx hardhat node
    npx hardhat run scripts/deploy.js --network localhost
    npm run dev

Error - 2

Error: default_default.default is not a function

solution:
npm i ethers@5.5.1 ipfs-http-client@50.1.2 @babel/core --save

Error-3 

metamask Failed transaction
reset account transaction record.

Error-4

```
Error: missing revert data in call exception (error={"reason":"processing response error","code":"SERVER_ERROR","body":"{\"jsonrpc\":\"2.0\",\"id\":46,\"error\":{\"code\":-32603,\"message\":\"Error: VM Exception while processing transaction: reverted with reason string 'ERC721URIStorage: URI query for nonexistent token'\"}}","error":{"code":-32603},"requestBody":"{\"method\":\"eth_call\",\"params\":[{\"to\":\"0xe7f1725e7734ce288f8367e1bb143e90bb3f0512\",\"data\":\"0xc87b56dd0000000000000000000000000000000000000000000000000000000000000000\"},\"latest\"],\"id\":46,\"jsonrpc\":\"2.0\"}","requestMethod":"POST","url":"http://localhost:8545"}, data="0x", code=CALL_EXCEPTION, version=providers/5.5.0)
```



