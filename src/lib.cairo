#[starknet::contract]
mod ERC20Token {
    use starknet::storage::StoragePointerWriteAccess;
use starknet::storage::StoragePointerReadAccess;
use openzeppelin_token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use openzeppelin_access::ownable::OwnableComponent;
    use starknet::ContractAddress;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // ERC20 Mixin
    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,

        treasury: ContractAddress
    }



    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        RunAI: RunAI
    }

    #[derive(Drop, starknet::Event)]
    struct RunAI {
        payerAddress: ContractAddress,
        royaltyAddress: ContractAddress,
        computeAmount: u256,
        royaltyAmount: u256
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        fixed_supply: u256,
        recipient: ContractAddress,
        owner: ContractAddress,
        treasuryIn: ContractAddress
    ) {
        // erc20 init
        self.erc20.initializer(name, symbol);
        self.erc20.mint(recipient, fixed_supply);
        // ownable init
        self.ownable.initializer(owner);

        // other
        self.treasury.write(treasuryIn);
    }


    // deduct (compute + royalty) tokens from the payerAddress
    // computeAmount goes to host
    // royaltyAmount goes to the model creator
    #[external(v0)]
    fn runAI(
        ref self: ContractState,
        payerAddress: ContractAddress,
        royaltyAddress: ContractAddress,

        computeAmount: u256,
        royaltyAmount: u256
    ) {
        // This function can only be called by the owner
        self.ownable.assert_only_owner();

        // check if the payer has enough tokens
        assert(self.erc20.balanceOf(payerAddress) >= (computeAmount + royaltyAmount), 1);

        // transfer the computeAmount to the host
        let treasuryAddress = self.treasury.read();
        self.erc20.transferFrom(payerAddress, treasuryAddress, computeAmount);

        // transfer the royaltyAmount to the model creator
        self.erc20.transferFrom(payerAddress, royaltyAddress, royaltyAmount);

        // emit event
        self.emit(RunAI {
            payerAddress,
            royaltyAddress,
            computeAmount,
            royaltyAmount
        });
    }
}