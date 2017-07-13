pragma solidity ^0.4.11;

contract Rated {

  // 2/3 ADMIN can add/remove ADMIN, add/enable/disable ICO
  // ADMIN can add/remove RATER
  enum Role { NONE, ADMIN, RATER }

  struct ICO {
    string name;
    string symbol;
    uint num_criteria;
    bool active;
    uint[] rating;
    uint num_raters;
    mapping(address => bool) raters;
  }

  ICO[] public icos;
  mapping(address => Role) public users;

  event UserAdded(address userAddress, Role role);
  event UserRemoved(address userAddress);
  event ICOAdded(uint id);
  event ICOStatusChanged(uint id, bool active);
  event ICORated(uint id, address user, uint8[] rating);

  // Constructor
  function Rated() {
    users[msg.sender] = Role.ADMIN;
  }

  function rate(uint _id, uint8[] _rating) users_only {
    ICO ico = icos[_id];
    require(!ico.raters[msg.sender]);
    require(_rating.length == ico.num_criteria);
    for(uint i = 0; i < ico.num_criteria; i++) {
      require(_rating[i] <= 5);
      ico.rating[i] = (ico.rating[i]*ico.num_raters + _rating[i]*10000) / (ico.num_raters + 1);
    }
    ico.num_raters++;
    ICORated(_id, msg.sender, _rating);
  }

  // TODO - role restrictions, voting
  function add_ico(string _name, string _symbol, uint _num_criteria) admin_only {
    uint id = icos.length++;
    icos[id].name = _name;
    icos[id].symbol = _symbol;
    icos[id].num_criteria = _num_criteria;
    icos[id].active = true;
    ICOAdded(id);
  }

  function enable_ico(uint _id) admin_only {
    icos[_id].active = true;
    ICOStatusChanged(_id, true);
  }

  function disable_ico(uint _id) admin_only {
    icos[_id].active = false;
    ICOStatusChanged(_id, false);
  }

  // TODO - role restrictions, voting
  function add_rater(address _userAddress) admin_only {
    users[_userAddress] = Role.RATER;
    UserAdded(_userAddress, Role.RATER);
  }

  function remove_rater(address _userAddress) admin_only {
    delete users[_userAddress];
    UserRemoved(_userAddress);
  }

  function propose_add_admin(address _userAddress) admin_only {  }

  function propose_remove_admin(address _userAddress) admin_only {  }

  modifier users_only() {
    require(users[msg.sender] != Role.NONE);
    _;
  }

  modifier admin_only() {
    require(users[msg.sender] == Role.ADMIN);
    _;
  }

}
