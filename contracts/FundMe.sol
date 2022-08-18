// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256; // to check for overflow on uint 256
   // to keep track of the funding 
    mapping(address => uint256) public addressToAmountFunded;
     address[] public funders; //array that we can loop through and set balance to 0
     address public owner; //to set ownder
     AggregatorV3Interface public priceFeed;

    // creating a constructor to create the owner immediately the contract gets deployed
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed); // to help mocking to avoid using hard coded address in "getVersion and getPrice"
        owner = msg.sender; // to indicate that owner is the one that sends the contract
    }

    // payable is used tomean that function can be used to pay for things 
    function fund() public payable {
        //$50
        // uint256 minimumUSD = 50 * 10 ** 18;
        uint256 minimumUSD = 50 * 10 * 18; // to get the minimum amount that is set
        require (getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!"); // if conversion rate/ether is not enough then revert the transaction
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        // we need to know what the ETH -> USD conversion rate is
    }

    //to Demo working with interfaces.by using the imported chainlink 
    function getVersion () public view returns (uint256){
        //to initialize the contract
        // we get the rinkby address from "https://docs.chain.link/docs/ethereum-addresses/" ETH / USD
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    // to call the price in the contract.AggregatorV3Interface is the type of contract that we want to call from chainlink.
    function getPrice () public view returns (uint256){
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,)= priceFeed.latestRoundData();
        return uint256 (answer * 10000000000); //casting int to uint256
    }

    //function to convert sent value to USD
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice ();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    // function to check owner from different function. Do the require first then run rest of the code
    modifier onlyOwner {
        require(msg.sender == owner );
        _; // do rest of the code
    }

    // function to withdraw the funding/money/ETH
    function withdraw() payable onlyOwner public{ 
        // this is used to refer to the contract we are currently in. Address is of the contract we are currently in.
        // Balance will show in eth of the contract. 
        // require(msg.sender == owner);// to declare that the owner is the only one to withdraw the contract using his address
        msg.sender.transfer(address(this).balance); // transfer is called to send eth fromone address to another
         for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++ ){ // for loop to reset balance in mapping to 0
              address funder = funders[funderIndex];
              addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); // reset funder array
    }
}