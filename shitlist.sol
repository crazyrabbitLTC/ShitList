pragma solidity ^0.4.18;

contract WhistleBlower {

    //ContractOwner
    address Owner;

    uint ClaimTime = 0; //How long to wait to reclaim funds in Block Numbers
    uint ClaimCheckTime = 0; //How long to wait between claim checks in Block Number

    uint StartUp = 1; //Are we in Startup Mode?

    //donation pools
    uint Donations;

    mapping(string => uint) numberOfClaims; //number of claims per hash
    mapping(string => mapping(uint => string)) detailsOfClaim; //details of claim

    mapping(address => string) onePerAddress; //Track One Type of Claim per address


    //Track the amount Claiments Stake
    struct claims {
        uint date;
        uint amount;
        bool claimed;
    }

    //Track amount of time between addresses checking
    mapping(address => uint) LastChecked; //The Uint is time or blocknumber.
    mapping(address => mapping(string => claims)) Refundtracker;

    //Money sent to contract goes to donation pool.
    //Consider adding "Ownable" as well.
    function WhistleBlower() payable public {
        //Money sent to the contract is taken as donation.
        Donations += msg.value;

        //Set Startup Mode //maybe we don't need to set this.
        //StartUp = 1;

        //Setup Claim Times
        ClaimTime = 0;
        ClaimCheckTime = 0;

        //Setup Owner of the contract
        Owner = msg.sender;
        return();
    }
    modifier onlyOwner {
        require(msg.sender == Owner);
        _;
    }

    function makeClaim(string _hash, string _details) public payable {
        //Require Staking Payment
        //Require Strings are not Empty
        //Maybe there is a more effecient way to do this.
        require(msg.value >= 500 finney);
        
        //This could be checked in the Javascript
        require(keccak256(_hash) != keccak256(""));
        require(keccak256(_details) != keccak256(""));


        /*Log Time of Claim
        var _refundtracker = Refundtracker[msg.sender][_hash];
        _refundtracker.date = block.timestamp;
        //Log amount Staked by user
        _refundtracker.amount = msg.value;
        */
        Refundtracker[msg.sender][_hash].date = block.timestamp;
        Refundtracker[msg.sender][_hash].amount = msg.value;
        LastChecked[msg.sender] = block.timestamp;
        
        //Number of Claims made against particular individual
        //uint _index = numberOfClaims[_hash];
        
        //Details of Claim
        detailsOfClaim[_hash][numberOfClaims[_hash]] = _details;

        //Total Number of Claims
        numberOfClaims[_hash] += 1;

    }

////////////////////
//Helper Functions//
////////////////////

    function returnClaimedCoins(address _claiment, string _hash) public {
        //You can only request the return of your own coins.
        require(msg.sender == _claiment);
        //Check that this has not already been redeemed
        require(Refundtracker[msg.sender][_hash].claimed == false);
        //Check that enough time has elapsed to redeem coins
        //uint _claimCreatedTime = Refundtracker[msg.sender][_hash].date;

        require(((Refundtracker[msg.sender][_hash].date) + ClaimTime) < block.timestamp);

        uint _amountToSend;
        _amountToSend = Refundtracker[msg.sender][_hash].amount;
        msg.sender.transfer(_amountToSend);
        Refundtracker[msg.sender][_hash].claimed = true;
        //msg.sender.call.value(_amountToSend).gas(50000)();
        //return(true);
    }


    function getClaimTimes() view public returns(uint,uint){
        return(ClaimTime, ClaimCheckTime);

    }
    function setClaimTimes(uint _claimtime, uint _claimchecktime) onlyOwner public /*returns()*/ {
        //Check to be sure we are in Statup Mode
        require((ClaimTime == 0) && (ClaimCheckTime == 0) );

        //Set our ClaimTime requirements
        ClaimTime = _claimtime;
        ClaimCheckTime = _claimchecktime;

        //Set Startup to False, thus ending the startup time. Forever.
        //StartUp = 0;
        //return();
    }

    function areWeInSetup() view public returns(bool){
        if ((ClaimTime == 0) && (ClaimCheckTime == 0))
            return(true);

    }

    function withdrawDonation(address _withdrawlAddress, uint _amount) onlyOwner public returns(bool){
        //Transfer Donations out
        _withdrawlAddress.transfer(_amount);
    }

    function makeDonation() public payable{
        Donations += msg.value;
    }

    function checkDonationBalance() view public returns(uint){
        return(Donations);
    }

    function checkContractBalance() view public returns(uint){
        return(address(this).balance);
    }

    function setLastCheckedTime(address _address) public {
        LastChecked[_address] = block.timestamp;
       
    }

    function getLastCheckedTime(address _address) view public returns(uint){
        return(LastChecked[_address]);
    }
    function getNumberofClaims(string _name) view public returns (uint){
        return(numberOfClaims[_name]);
    }

    function getDetails(string _name, uint _claimnumber) view public returns (string){

        string memory _details = detailsOfClaim[_name][_claimnumber];
        return(_details);
    }

}
