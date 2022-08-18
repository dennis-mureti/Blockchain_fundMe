from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy import deploy_fund_me
from brownie import network, accounts,exceptions
import pytest

def test_can_fund_and_withdraw():
    account = get_account()
    fund_me = deploy_fund_me()
    entrance_fee = fund_me.getEntranceFee() + 100
    tx = fund_me.fund({"from": account, "value": entrance_fee}) # now we go ahead and fund it
    tx.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == entrance_fee # to check that address and amount funded is adequately recorded
    tx2 = fund_me.withdraw({"from": account})
    tx2.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == 0

# to run test in local chain
# use of pytest skip functionality 
# test to make sure that the owner is the only one that can withdraw
def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("only for local testing")
    fund_me = deploy_fund_me()
    bad_actor = accounts.add() # now we  get diff account to try call the withdraw function
    with pytest.raises(exceptions.VirtualMachineError): # now we tell brownie what exception we expect to see
        fund_me.withdraw({"from": bad_actor})



    # brownie test -> to run test
    # brownie test -k test_only_owner_can_withdraw -> to test forlocal anvironment using pytest