use starknet::ContractAddress;

#[starknet::interface]
pub trait IAgentForge<TContractState> {
    fn get_balance(self: @TContractState, address: ContractAddress) -> u128;
    fn credit(ref self: TContractState, owner: ContractAddress, wallet: ContractAddress, amount: u128);
    fn debit(ref self: TContractState, owner: ContractAddress, wallet: ContractAddress, computeAmount: u128, royaltyAddress: ContractAddress, royaltyAmount: u128);
    fn set_price(ref self: TContractState, owner: ContractAddress, price: u128);
    fn get_price(ref self: TContractState) -> u128;
}

#[starknet::contract]
mod AgentForge {
    use core::starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use core::starknet::event::EventEmitter;
    // TODO: figure out global import, need to call both in contract and on page to use ContractAddress
    // Royalty address?
    // Token Price Setter? 

    #[storage]
    struct Storage {
        balances: Map<ContractAddress, u128>,
        owner: ContractAddress,
        price: u128, // Price of AGTF for exmaple: 1 STRK == 20 AGTF 
    }

    #[derive(Drop, starknet::Event)]
    struct RunAI {
        wallet: ContractAddress,
        royaltyAddress: ContractAddress,
        computeAmount: u128,
        royaltyAmount: u128
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RunAI: RunAI
    }

    #[abi(embed_v0)]
    impl AgentForge of super::IAgentForge<ContractState> {
        fn get_balance(self: @ContractState, address: ContractAddress) -> u128 {
            let balance = self.balances.read(address);
            return balance;
        }

        fn credit(ref self: ContractState, owner: ContractAddress, wallet: ContractAddress, amount: u128) {
            // Add a function to do conversion of STRK to AGTF
            let caller = get_caller_address();
            if caller == self.owner.read() {
                let wallet_balance = self.balances.read(wallet);
                self.balances.write(wallet, wallet_balance + amount);    
            } else {
                panic!("Only AgentForge can credit the wallet");
            }
            
        }

        fn debit(ref self: ContractState, owner: ContractAddress, wallet: ContractAddress, computeAmount: u128, royaltyAddress: ContractAddress, royaltyAmount: u128) {
            //  TODO:   -Royalties to be deducted from the TX for AI 
            // Add a function to do conversion of STRK to AGTF
            let caller = get_caller_address();
            if caller == self.owner.read() {
                let wallet_balance = self.balances.read(wallet);
                self.balances.write(wallet, wallet_balance - computeAmount - royaltyAmount);  

                //  TODO: Fix event emitter  
                self.emit(RunAI {
                    wallet,
                    royaltyAddress,
                    computeAmount,
                    royaltyAmount
                });

            } else {
                panic!("Only AgentForge can dedit the wallet");
            }
        }

        fn set_price(ref self: ContractState, owner: ContractAddress, price: u128) {
            let caller = get_caller_address();
            if caller == self.owner.read() {
                self.price.write(price);
            } else {
                panic!("Only AgentForge can set the price");
            }
        }

        fn get_price(ref self: ContractState) -> u128 {
            return self.price.read();
        }
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        // set owner
        let _owner = get_caller_address(); 
        self.owner.write(_owner);

        // set initial price
        self.price.write(20);
        
    }
}