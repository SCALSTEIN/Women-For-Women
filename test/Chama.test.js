const { assert } = require("console");
//const Web3 = require('web3');

const Chama = artifacts.require("Chama");
contract("Chama", () => {

  describe("Chama DApp", function(){
    it("Should track the first chama details created upon contract deployment", () => {
      Chama.deployed()
        .then((instance) => instance.chamaManager())
        .then((manager) => {
          assert.equal(manager, deployAddress, "Not the correct address");
        });
    });
    it("should join first member to the Chama", () => {
        Chama.deployed()
        .then(instance => instance.joinChama())
        .then(memberID => {
            assert.equal(memberID, 1, "Wrong memberID!")
        })
    })
  })
  
});




/**const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const web3 = new Web3(ganache.provider());
const json = require("../client/src/contracts/Chama.json");


let accounts;
let chama;
let manager;
const interface = json["abi"];
const bytecode = json["bytecode"];

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();
  manager = accounts[0];
  chama = await new web3.eth.Contract(interface)
    .deploy({ data: bytecode })
    .send({ from: manager, gas: "1000000" });
});
describe("Chama Deployment", () => {
  it("Deploys the contract", async () => {
    const chamManager = await chama.methods.manager.call();
    assert.equal(
      manager,
      chamManager,
      "The manager is the one who launches the smart contract"
    );
  });
  it("Should track the chama details of the chama created once contract is deployed", async () => {
    const chmId = 1;
    const _name = 'women254';
    const chmManager = manager;
    const regFee = 3;
    const prem = 3;
    const target = 50;
    const disbPeriod = 408000;
    assert(await chama.chamaCount()).equal(chmId);
    assert(await chama._nam()).equal(_name);
    assert(await chama.chamaManager1()).equal(chmManager);
    assert(await chama._registrationFee()).equal(regFee);
    assert(await chama._premium()).equal(prem);
    assert(await chama._target()).equal(target);
    assert(await chama._reemittancePeriod()).equal(disbPeriod);
  });
});

describe("Chama creation", () => {
  it("Should only allow an aspiring chama manager with 3 eth to create a chama", async () => {
    const chmManager = accounts[1];
    await chama.connect(chmManager).createRandomChama('InuaMama',3,3,45,408000);
    assert(await chama.balanceOf(chmManager.address)).equal("3000000000000000000");

  })
})
 */

