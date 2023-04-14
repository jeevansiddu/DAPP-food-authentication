// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;
import "./DateTime.sol";

error food_authentication__idfound();
error food_authentication__idnotfound();
error food_authentication__Notowner();
error food_authentication__itemexpired();
error food_authentication__foodeaten();

//keccak256(bytes(a)) == keccak256(bytes(b));
contract food_authentication is DateTime {
    struct food_item {
        string name;
        string manufacture_date;
        uint256 expirytimestamp;
        string origin;
        bool iscomsumed;
        string curr_location;
        string travel_history;
        uint256 startingtimestamp;
    }
    uint256 public food_id;
    address immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    food_item food;
    mapping(uint256 => food_item) public foodidtoitem;

    function addfooditem(
        string calldata _name,
        uint256 foodid,
        string calldata date,
        string calldata _org,
        string calldata loc
    ) public onlyowner {
        // foodidtoitem(foodid);
        // string memory name = foodidtoitem[foodid].name;
        if (
            keccak256(bytes(foodidtoitem[foodid].name)) != keccak256(bytes(""))
        ) {
            revert food_authentication__idfound();
        } else {
            food.name = _name;
            food.manufacture_date = date;
            food.origin = _org;
            // food.expirytimestamp = toTimestamp(year, month, day);
            food.iscomsumed = false;
            food.curr_location = loc;
            food.travel_history = loc;
            foodidtoitem[foodid] = food;
        }
    }

    // 1681293780
    //1681293708
    function setExpirydate(
        uint256 id,
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute
    ) public onlyowner {
        uint256 k = toTimestamp(year, month, day, hour, minute) - 19800;
        foodidtoitem[id].expirytimestamp = k;
    }

    function changecurrentlocation(uint256 id, string memory _loc) public {
        foodidtoitem[id].travel_history = string.concat(
            foodidtoitem[id].travel_history,
            " "
        );
        foodidtoitem[id].travel_history = string.concat(
            foodidtoitem[id].travel_history,
            _loc
        );

        foodidtoitem[id].curr_location = _loc;
    }

    function selltoconsumer(uint256 id) public {
        bool iseaten = foodidtoitem[id].iscomsumed;
        if (iseaten == true) {
            revert food_authentication__foodeaten();
        } else {
            bool isgood = isauthentic(id);
            if (isgood == true) {
                foodidtoitem[id].iscomsumed = true;
            } else {
                revert food_authentication__itemexpired();
            }
        }
    }

    function isauthentic(uint256 id) public view returns (bool) {
        uint256 endingtimestamp = block.timestamp;
        if (keccak256(bytes(foodidtoitem[id].name)) == keccak256(bytes(""))) {
            revert food_authentication__idnotfound();
        }
        if (endingtimestamp >= foodidtoitem[id].expirytimestamp) {
            return false;
        } else {
            return true;
        }
    }

    function getTravelHistory(uint id) public view returns (string memory) {
        return foodidtoitem[id].travel_history;
    }

    function getExpiryTimeStamp(uint id) public view returns (uint) {
        return foodidtoitem[id].expirytimestamp;
    }

    function getManufactureDate(uint id) public view returns (string memory) {
        return foodidtoitem[id].manufacture_date;
    }

    function isIdPresent(uint id) public view returns (bool) {
        if (keccak256(bytes(foodidtoitem[id].name)) != keccak256(bytes(""))) {
            return true;
        } else return false;
    }

    function getfoodnamebyid(uint256 id) public view returns (string memory) {
        string memory name = foodidtoitem[id].name;
        if (keccak256(bytes(name)) == keccak256(bytes(""))) {
            revert food_authentication__idnotfound();
        }
        return foodidtoitem[id].name;
    }

    function isFoodConsumed(uint256 id) public view returns (bool) {
        return foodidtoitem[id].iscomsumed;
    }

    function getCurrentTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    modifier onlyowner() {
        // require(msg.sender==i_owner,"Not the right person");
        if (msg.sender != i_owner) {
            revert food_authentication__Notowner();
        }
        _;
    }

    receive() external payable {}

    fallback() external payable {}
}
