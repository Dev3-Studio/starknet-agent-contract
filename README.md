scarb build

scarb cairo-run

## Practise contract on sepolia

Public key: 0x0185f28932ef6ea781218d3168e05cf0c0ce126b1d107f86e99976a99b6add8b

Enter keystore password:
The estimated account deployment fee is 0.000463469478431074 STRK. However, to avoid failure, fund at least:
0.001022359142145675 STRK
to the following address:
0x05e80a8db8c2fc5a4ab259cb7fd00b3c882389e2ae4f865ac1e987c1544d3a03
Press [ENTER] once you've funded the address.

Class hash:
0x007c93bd60df0fc14aebbf531d355c5b083f9d68d510fd2d6d1c2557e5ca3690

Deploying class 0x007c93bd60df0fc14aebbf531d355c5b083f9d68d510fd2d6d1c2557e5ca3690 with salt 0x04859c4fa91e8ed7a29333189292d403d28eb577f59659c99e9dd492567fd546...
The contract will be deployed at address 0x050eeede51988dd21d779e7eed0daf3632e91ab7e770471cf991c2f6cb9b6b2f
Contract deployment transaction: 0x026c47acc88d3f4dbf00574465e33d15d755c964235777888b3931efbdcf7e12
Contract deployed:
0x050eeede51988dd21d779e7eed0daf3632e91ab7e770471cf991c2f6cb9b6b2f

---

## Contract Guidelines

Note: A new contract should be build and deployed, pay special attention to the declaration process, for more information on hot to use Starkli visit: https://book.starkli.rs/tutorials/starkli-101
STARK TOKEN ADDRESS:  
0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d

## Work Closely with the Cairo Contract to ensure the correct parameters are passed to the constructor.

1.  starkli declare target/dev/agentforge_AgentForge.contract_class.json --strk

2.  starkli deploy 0x007c93bd60df0fc14aebbf531d355c5b083f9d68d510fd2d6d1c2557e5ca3690 0x05e80a8db8c2fc5a4ab259cb7fd00b3c882389e2ae4f865ac1e987c1544d3a03 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d --strk
    starkli deploy <CLASS_HASH> <CTOR_ARGS>

3.  starkli invoke 0x050eeede51988dd21d779e7eed0daf3632e91ab7e770471cf991c2f6cb9b6b2f set_price 30 0 --strk
    starkli invoke <ADDRESS> <SELECTOR> <ARGS>

4.  starkli invoke 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d approve 0x050eeede51988dd21d779e7eed0daf3632e91ab7e770471cf991c2f6cb9b6b2f 30 0 --strk
    starkli invoke <ADDRESS> <SELECTOR> <ARGS>

5.  starkli invoke 0x050eeede51988dd21d779e7eed0daf3632e91ab7e770471cf991c2f6cb9b6b2f debit 0x05e80a8db8c2fc5a4ab259cb7fd00b3c882389e2ae4f865ac1e987c1544d3a03 0x05e80a8db8c2fc5a4ab259cb7fd00b3c882389e2ae4f865ac1e987c1544d3a03 1 0 0x05e80a8db8c2fc5a4ab259cb7fd00b3c882389e2ae4f865ac1e987c1544d3a03 1 0 --strk
    starkli invoke <ADDRESS> <SELECTOR> <ARGS>

6.  starkli invoke 0x050eeede51988dd21d779e7eed0daf3632e91ab7e770471cf991c2f6cb9b6b2f redeem --strk
    starkli invoke <ADDRESS> <SELECTOR> <ARGS>
