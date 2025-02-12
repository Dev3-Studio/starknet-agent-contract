use starknet::{ContractAddress, contract_address_const};

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use agentforge::IAgentForgeDispatcher;
use agentforge::IAgentForgeDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

fn deploy_contract_factory() -> (IAgentForgeDispatcher, ContractAddress) {
    let contract = declare("AgentForge").unwrap().contract_class();

    let owner: ContractAddress = contract_address_const::<'owner'>();
    let constructor_calldata = array![owner.into()];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    let dispatcher = IAgentForgeDispatcher { contract_address };

    (dispatcher, contract_address)
}


#[test]
fn test_get_balance() {
    let (contract_factory, contract_factory_address) = deploy_contract_factory();

    let balance = contract_factory.get_balance(contract_factory_address);

    assert(balance == 0, 'Invalid balance');
}

#[test]
fn test_credit() {
    let (contract_factory, contract_factory_address) = deploy_contract_factory();

    let balance = contract_factory.get_balance(contract_factory_address);

    assert(balance == 0, 'Invalid balance');

    contract_factory.credit(contract_factory_address, contract_factory_address, 42);

    let balance = contract_factory.get_balance(contract_factory_address);

    assert(balance == 42, 'Valid balance');
}

#[test]
fn test_debit() {
    let (contract_factory, contract_factory_address) = deploy_contract_factory();

    let balance = contract_factory.get_balance(contract_factory_address);

    assert(balance == 0, 'Invalid balance');

    contract_factory.credit(contract_factory_address, contract_factory_address, 42);

    let balance = contract_factory.get_balance(contract_factory_address);
    assert(balance == 42, 'Valid balance');

    contract_factory.debit(contract_factory_address, contract_factory_address, 21, contract_factory_address, 3);

    let balance = contract_factory.get_balance(contract_factory_address);
    assert(balance == 18, 'Correct balance');

}

#[test]
fn test_set_price() {
    let (contract_factory, contract_factory_address) = deploy_contract_factory();
    let price = 20;
    contract_factory.set_price(contract_factory_address, price);
    let fetched_price = contract_factory.get_price();
    assert(fetched_price == 20, 'Valid price');
}