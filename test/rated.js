var Rated = artifacts.require("./Rated.sol");

contract('Rated', function(accounts) {
  it("account[0] is Role.ADMIN (1)", function() {
    return Rated.deployed().then(function(instance) {
      return instance.users.call(accounts[0]);
    }).then(function(role) {
      assert.equal(role.valueOf(), 1, "account[0] did not have Role.ADMIN (1)");
    });
  });
});
