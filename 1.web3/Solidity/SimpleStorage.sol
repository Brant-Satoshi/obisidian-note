// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// pragma solidity ^0.8.0;
// pragma solidity >=0.8.0 <0.9.0;

contract SimpleStorage {
    // favoriteNumber gets initialized to 0 if no value is given
    uint256 myFavoriteNumber;
    // uint[] listIfFavoriteNumbers; // [0, 1, 2]

    struct Person {
        uint256 favoriteNumber;
        string name;
    }

    // Person public pat = Person({favoriteNumber: 7, name: "Pat"});
    // dynamic array
    Person[] public listOfPeople; //[]

    mapping(string => uint256) public nameToFavoriteNumber;
    // static array 
    // Person[3] public listOfPeople2;


    function store(uint256 _favoriteNumber) public {
        myFavoriteNumber = _favoriteNumber;
    }

    // view, oure
    function retrieve() public view returns (uint256) {
        return myFavoriteNumber;
    }

    // calldata, memory, storage
    function addPerson(string memory _name, uint256 _favoriteNumber) public  {
        listOfPeople.push( Person(_favoriteNumber, _name) );
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}