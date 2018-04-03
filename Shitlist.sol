pragma solidity ^0.4.21;

contract Shitlist{
    
    //mapping of times a Name is found
    mapping(string => uint) countevents;
    
    //mapping of name to mapping of case number to string of IPFS - Text Details
    mapping(string => mapping(uint => string)) database;
    //mapping of name to mapping of case number to image file for evidence.
    mapping(string => mapping(uint => string)) imageFiles;
    
    struct Victim {
        address person;
        uint stake;
        uint time;
    }
    
    //mapping of victim to accused to amount staked and when
    mapping(address => mapping(string =>Victim)) victimDatabase;
    
    uint RefundTime;
    uint MinimumStake;
    
    function Shitlist(uint _refundtime, uint _minimumStake) public {
        RefundTime = _refundtime;
        MinimumStake = _minimumStake;
        
    }
    
    function makeClaim(string _name, string _ipfs, string _ipfsImage) payable public {
        //many things to check- how many claims they make, did they make a claim before, etc...
        countevents[_name] += 1;
        database[_name][countevents[_name]] = _ipfs;
        imageFiles[_name][countevents[_name]] = _ipfsImage;
        victimDatabase[msg.sender][_name].person = msg.sender;
        victimDatabase[msg.sender][_name].stake = msg.value;
        victimDatabase[msg.sender][_name].time = block.timestamp;
    }
    
    function checkClaimExists(string _name) view public returns(uint){
        //later they should check only 12 hours
        if(countevents[_name] == 0)
            return(0);
        else
            return(countevents[_name]);
    }
    
    function getClaimDetails(string _name, uint _number) view public returns(string, string){
        require(_number >= 1);
        require(keccak256(database[_name][_number]) != keccak256(""));
        return(database[_name][_number],imageFiles[_name][_number]);
    }
    
    function refundStake(string _name, address _addressRefunded)  public {
        require(victimDatabase[_addressRefunded][_name].stake > 0);
        require(victimDatabase[_addressRefunded][_name].time <= block.timestamp + RefundTime);
        _addressRefunded.transfer(victimDatabase[_addressRefunded][_name].stake);
        
    }
    
}