use agentforge::IAgentForgeDispatcherTrait;
use starknet::{ContractAddress, contract_address_const};

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use agentforge::IAgentForgeDispatcher;
// use agentforge::IAgentForgeDispatcherTrait;

fn deploy_contract() -> (IAgentForgeDispatcher, ContractAddress) {
    let contract = declare("AgentForge").unwrap().contract_class();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    // let constructor_calldata = array![owner.into()];

    let (contract_address, _) = contract.deploy(@array![owner.into()]).unwrap();
    // let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    let dispatcher = IAgentForgeDispatcher { contract_address };

    return (dispatcher, contract_address);
}




#[test]
fn test_get_balance() {
    let (contract, _) = deploy_contract();

    let balance = contract.get_balance(contract_address_const::<'owner'>());

    assert(balance == 0, 'Balance should be 0');

}

#[test]
fn test_credit() {
    let (contract_factory, contract_factory_address) = deploy_contract();

    let balance = contract_factory.get_balance(contract_factory_address);

    assert(balance == 0, 'Invalid balance');

    contract_factory.credit(contract_factory_address, 42);

    let balance = contract_factory.get_balance(contract_factory_address);

    assert(balance == 42, 'Valid balance');
}


// #[test]
// fn dedit_test() {
//     let (contract, _) = deploy_contract();

//     let owner = contract_address_const::<'owner'>();
//     // let wallet = contract_address_const::<'owner'>();


//     let balance = contract.get_balance(owner);

//     assert(balance == 0, 'Balance should be 0');

//     contract.credit(owner, 100);

//     let balance_after_credit = contract.get_balance(owner);
//     assert(balance_after_credit == 100, 'Balance should be 100');

//     contract.debit(owner, owner, 25, owner, 50);

//     let balance_after_debit = contract.get_balance(owner);
//     assert(balance_after_debit == 50, 'Balance should be 50');

// }