const Crud = artifacts.require("Crud");

contract("Crud", () => {
  let crud = null;
  before(async () => {
    crud = await Crud.deployed();
  });

  it("Should be create a player", async () => {
    await crud.create("Quang Vu");
    const player = await crud.read(1);
    assert(player[0].toNumber() === 1);
    assert(player[1] === "Quang Vu");
  });

  it("Should be upload player", async () => {
    await crud.upload(1, "Quang Vu Dep Trai");
    const player = await crud.read(1);
    assert(player[0].toNumber() === 1);
    assert(player[1] === "Quang Vu Dep Trai");
  });

  it("Should be return revert is player don't exist", async () => {
    try {
      await crud.upload(2, "Quang Vu 2");
    } catch (e) {
      assert(e.message.includes("Player does not exist"));
      return;
    }
    assert(false);
  });

  it("Should be destroy a player", async () => {
    await crud.destroy(1);
    try {
      await crud.read(1);
    } catch (e) {
      assert(e.message.includes("Player does not exist"));
      return;
    }
    assert(false);
  });

  it("Should be destroy a player unhappy testing", async () => {
    try {
      await crud.destroy(10);
    } catch (e) {
      assert(e.message.includes("Player does not exist"));
      return;
    }
    assert(false);
  });
});
