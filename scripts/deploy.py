from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from web3 import Web3



def deploy_fund_me():
    account = get_account()
    # now we pass theprice feed address to ourfund me contract

    # if we  are on a persistent network like rnkeby, use the associated address as below
    # otherwiswe we deploy a mock
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS: #if we are on a development chain 
        price_feed_address = config["networks"][
            network.show_active()]["eth_usd_price_feed"]
        
        # else we deploy a mock
    else:
        deploy_mocks() #for deploying mock which we created it from the helpful scripts
        price_feed_address = MockV3Aggregator[-1].address # to get address # now weuse the most recently deployed mockV3aggregator after using the if statement

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"), #to helpin identifyin the network 
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me

def main():
    deploy_fund_me()
