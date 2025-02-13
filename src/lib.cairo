use starknet::ContractAddress;

#[starknet::interface]
pub trait IAgentForge<TContractState> {
    // Retrieves an address' current internal balance
    fn get_balance(self: @TContractState, wallet: ContractAddress) -> u256;

    // Transfers `amount` STRK out of the user's wallet and credits the user's internal balance with
    // an equivalent amount according to the fixed conversion rate STRK transfers to owners address
    // from the caller's address @param `amount` Amount of STRK to transfer out
    // Emit a "Credit" event showing the caller's balance change
    fn credit(ref self: TContractState, wallet: ContractAddress, amount: u256);

    // Reduces `wallet` internal balance by `computeAmount + royaltyAmount`
    // @param `wallet` Wallet to debit balance from
    // @param `computeAmount` Amount credited to treasury wallet balance
    // @param `royaltyAddress` Wallet to receive `royaltyAmount`
    // @param `royaltyAmount` Amount credited to royalty address
    // Function MUST only be callable by contract owner: "self.ownable.assert_only_owner();"
    // Emit a "Debit" event showing the deduction of internal balance from `wallet`
    // Emit a "Credit" event showing the increase in balance for treasury address
    // Emit a "Credit" event showing the increase in balance for the royalty address
    fn redeem(ref self: TContractState);

    // Reduces the caller's internal balance mapping by `amount`,
    // Transfers equivalent of STRK tokens to caller's address
    // @param `amount` Amount to reduce caller's internal balance by
    // Emit a "Debit" event showing the deduction of internal balance from caller's wallet
    // Function MUST only be callable by contract owner: "self.ownable.assert_only_owner();"
    fn debit(
        ref self: TContractState,
        owner: ContractAddress,
        wallet: ContractAddress,
        computeAmount: u256,
        royaltyAddress: ContractAddress,
        royaltyAmount: u256,
    );

    // Set the fixed conversion rate between STRK and internal balance mapping
    // @param `price` Number of internal balance per STRK
    // Function MUST only be callable by contract owner: "self.ownable.assert_only_owner();"
    fn set_price(ref self: TContractState, owner: ContractAddress, price: u256);

    // Get the current conversion rate between STRK and internal balance mapping.
    fn get_price(ref self: TContractState) -> u256;
}

#[starknet::contract]
mod AgentForge {
    // TODO:
    // Royalty address?
    // Token Price Setter?
    use core::starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_caller_address};
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use core::starknet::event::EventEmitter;
    use openzeppelin::access::ownable::OwnableComponent;

    #[storage]
    struct Storage {
        balances: Map<ContractAddress, u256>,
        owner: ContractAddress,
        price: u256, // Price of AGTF for exmaple: 1 STRK == 20 AGTF 
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        stark_address: ContractAddress,
    }

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[derive(Drop, starknet::Event)]
    struct RunAI {
        wallet: ContractAddress,
        royaltyAddress: ContractAddress,
        computeAmount: u256,
        royaltAmount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Credit {
        wallet: ContractAddress,
        amount: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        RunAI: RunAI,
        Credit: Credit,
    }

    // pick a better name for this function
    fn convertSTRKtoAGTF(price: u256, amount: u256) -> u256 {
        return price * amount;
    }

    // pick a better name for this function
    fn convertAGTFtoSTRK(price: u256, amount: u256) -> u256 {
        return amount / price;
    }


    #[abi(embed_v0)]
    impl AgentForge of super::IAgentForge<ContractState> {
        fn get_balance(self: @ContractState, wallet: ContractAddress) -> u256 {
            let balance = self.balances.read(wallet);
            return balance;
        }

        fn redeem(ref self: ContractState) {
            // Add a function to do conversion of AGTF to STRK
            let caller = get_caller_address();
            let wallet_balance = self.balances.read(caller);
            let _redeemamount = convertAGTFtoSTRK(self.get_price(), wallet_balance);
        }

        fn credit(ref self: ContractState, wallet: ContractAddress, amount: u256) {
            // Take in their STRK
            // Syscalls?
            // ERC20?
            // 0xc662c410C0ECf747543f5bA90660f6ABeBD9C8c4
            // 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d

            let erc20_dispatcher = IERC20Dispatcher { contract_address: self.stark_address.read() };

            // how do we get the amount of STRK from the caller?
            // Issue AGTF tokens

            let agtf_amount = convertSTRKtoAGTF(self.price.read(), amount);
            let wallet_balance = self.balances.read(wallet);
            self.balances.write(wallet, wallet_balance + agtf_amount);
            // TODO: why is this throwing an error?
            self.emit(Credit { wallet: wallet, amount: agtf_amount });
        }

        fn debit(
            ref self: ContractState,
            owner: ContractAddress,
            wallet: ContractAddress,
            computeAmount: u256,
            royaltyAddress: ContractAddress,
            royaltyAmount: u256,
        ) {
            // TODO: Royalties to be deducted from the TX for AI
            // Add a function to do conversion of STRK to AGTF
            // Redeem AGTF for STRK
            self.ownable.assert_only_owner();

            let wallet_balance = self.balances.read(wallet);

            // debit user amount
            self.balances.write(wallet, wallet_balance - computeAmount - royaltyAmount);

            // transfer the computeAmount to the owner

            // transfer the royaltyAmount to the model creator

            self.emit(RunAI { wallet, royaltyAddress, computeAmount, royaltyAmount });
        }

        fn set_price(ref self: ContractState, owner: ContractAddress, price: u256) {
            self.ownable.assert_only_owner();
            let caller = get_caller_address();
            if caller == self.owner.read() {
                self.price.write(price);
            } else {
                panic!("Only AgentForge can set the price");
            }
        }

        fn get_price(ref self: ContractState) -> u256 {
            return self.price.read();
        }
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, strkAddress: ContractAddress) {
        // set owner
        let _owner = get_caller_address();
        self.owner.write(_owner);

        // set initial price
        self.price.write(20);
        self
            .strkAddress
            .write('0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d');
    }
}
