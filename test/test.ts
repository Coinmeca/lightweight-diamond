import { ethers } from "hardhat";
import { FacetCutAction, getSelectors } from "./utils";
import { ContractFactory } from "ethers";

describe("Diamond Test", function () {

  const Diamonds = [
    {
      key: 'market',
      data: [
        // Market facets
        'contracts/services/market/facets/Create.sol:Create',
        'contracts/services/market/facets/Get.sol:Get'
      ]
    },
    {
      key: 'orderbook',
      data: [
        // Orderbook facets will be storage in the Market for factory later.
        'contracts/services/orderbook/facets/Order.sol:Order',
        'contracts/services/orderbook/facets/Cancel.sol:Cancel',
        'contracts/services/orderbook/facets/Get.sol:Get'
      ]
    }
  ];

  let diamondCut: any[] = [];
  let diamondArgs: any = {};

  beforeEach(async function () {
    const accounts = await ethers.getSigners();

    diamondArgs = {
      owner: accounts[0].address,
      init: ethers.ZeroAddress,
      initCalldata: ethers.ZeroAddress
    }

    console.log("Deployer:", diamondArgs.owner, "(owner)");

    diamondCut = await Promise.all(Diamonds.map(async (d, i) => {
      return {
        ...d,
        data: await Promise.all(d.data.map(async (f, j) => {

          const facet = await (await ethers.getContractFactory(f)).deploy();
          console.log(`---------------------------------------------------------------`);
          console.log(`Diamond Name: ${d.key}`);
          console.log(`---------------------------------------------------------------`);
          console.log(`Facet Name: ${f}`);
          console.log(`Deployed Address: ${await facet.getAddress()}`);
          console.log(`Functions: ${await getSelectors(facet)}`);
          console.log(`---------------------------------------------------------------`);

          return {
            facetAddress: await facet.getAddress(),
            action: FacetCutAction.Add,
            functionSelectors: await getSelectors(facet)
          };
        }))
      }
    }))
  })


  it("", async function () {
    const tokens = await ethers.getSigners();

    // console.log(facetCuts, diamondArgs);
    console.log(':: Market Diamond Deploy ::');
    const market: ContractFactory = await ethers.getContractFactory("Market");
    console.log(`---------------------------------------------------------------`);
    console.log(diamondCut)
    console.log(`---------------------------------------------------------------`);
    const marketDiamond: any = await market.deploy(diamondCut, diamondArgs);
    console.log(`---------------------------------------------------------------`);
    console.log('Market: ', await marketDiamond.getAddress());
    console.log(`---------------------------------------------------------------`);

    describe('', () => {
      // factory orderbook1 diamond from market diamond
      it("New Orderbook 1 Diamond Create", async function () {
        console.log(':: New Orderbook 1 Diamond Create ::');
        await (await ethers.getContractAt(
          "contracts/services/market/facets/Create.sol:Create",
          await marketDiamond.getAddress())
        ).create(
          await tokens[1].getAddress(),
          await tokens[2].getAddress(),
          1000
        );

        const orderbookDiamondFacade1 = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Get.sol:Get",
          (await (await ethers.getContractAt(
            'contracts/services/market/facets/Get.sol:Get',
            await marketDiamond.getAddress())
          ).getAllMarkets())[0]);

        console.log('Orderbook 1 Price: ', await orderbookDiamondFacade1.getPrice());

        // factory orderbook2 diamond from market diamond
        console.log(':: New Orderbook 2 Diamond Create ::');
        await (await ethers.getContractAt(
          "contracts/services/market/facets/Create.sol:Create",
          await marketDiamond.getAddress())
        ).create(
          await tokens[3].getAddress(),
          await tokens[4].getAddress(),
          2000
        );

        const orderbookDiamondFacade2 = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Get.sol:Get",
          (await (await ethers.getContractAt(
            'contracts/services/market/facets/Get.sol:Get',
            await marketDiamond.getAddress())
          ).getAllMarkets())[1]);

        console.log('Orderbook 2 Price: ', await orderbookDiamondFacade2.getPrice());
      });

      it("", async function () {

        const orderbook1FacadeAddress = await (await (await ethers.getContractAt(
          'contracts/services/market/facets/Get.sol:Get',
          await marketDiamond.getAddress())
        ).getAllMarkets())[0];

        const orderbook1SupportInterface = await ethers.getContractAt('Orderbook', orderbook1FacadeAddress);

        const orderbook1OrderFacet = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Order.sol:Order",
          orderbook1FacadeAddress
        );

        const orderbook1CancelFacet = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Cancel.sol:Cancel",
          orderbook1FacadeAddress
        );

        const orderbook1GetFacet = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Get.sol:Get",
          orderbook1FacadeAddress
        );

        console.log(':: Orderbook 1 Shared Internal Function Test ::');
        console.log(`---------------------------------------------------------------`);
        console.log(
          'Market Support Interface[0x21603f43]: ',
          await await marketDiamond.supportsInterface('0x21603f43')
        );
        console.log(
          'Orderbook 1 Support Interface[0x21603f43]: ',
          await orderbook1SupportInterface["supportsInterface(bytes4)"]('0x21603f43')
        );
        console.log(`---------------------------------------------------------------`);

        await orderbook1OrderFacet.order(0, 250)
        console.log(`---------------------------------------------------------------`);
        console.log('Orderbook 1 Price: ', await orderbook1GetFacet.getPrice());
        console.log('Orderbook 1 Tick: ', await orderbook1GetFacet.getTick());
        console.log(`---------------------------------------------------------------`);

        await orderbook1OrderFacet.order(1, 750)
        console.log(`---------------------------------------------------------------`);
        console.log('Orderbook 1 Price: ', await orderbook1GetFacet.getPrice());
        console.log('Orderbook 1 Tick: ', await orderbook1GetFacet.getTick());
        console.log(`---------------------------------------------------------------`);

        await orderbook1CancelFacet.liquidation(10)
        console.log(`---------------------------------------------------------------`);
        console.log('Orderbook 1 Price: ', await orderbook1GetFacet.getPrice());
        console.log('Orderbook 1 Tick: ', await orderbook1GetFacet.getTick());
        console.log(`---------------------------------------------------------------`);

        const orderbook2FacadeAddress = (await (await ethers.getContractAt(
          'contracts/services/market/facets/Get.sol:Get',
          await marketDiamond.getAddress())
        ).getAllMarkets())[1];

        const orderbook2SupportInterface = await ethers.getContractAt('Orderbook', orderbook2FacadeAddress);

        const orderbook2OrderFacet = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Order.sol:Order",
          orderbook2FacadeAddress
        );

        const orderbook2CancelFacet = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Cancel.sol:Cancel",
          orderbook2FacadeAddress
        );

        const orderbook2GetFacet = await ethers.getContractAt(
          "contracts/services/orderbook/facets/Get.sol:Get",
          orderbook2FacadeAddress
        );

        console.log(':: Orderbook 2 Shared Internal Function Test ::');
        console.log(`---------------------------------------------------------------`);
        console.log(
          'Market Support Interface[0x21603f43]: ',
          await marketDiamond.supportsInterface('0x21603f43')
        );
        console.log(
          'Orderbook 2 Support Interface[0x21603f43]: ',
          await orderbook2SupportInterface["supportsInterface(bytes4)"]('0x21603f43')
        );
        console.log(`---------------------------------------------------------------`);

        await orderbook2OrderFacet.order(0, 1250)
        console.log(`---------------------------------------------------------------`);
        console.log('Orderbook 2 Price: ', await orderbook2GetFacet.getPrice());
        console.log('Orderbook 2 Tick: ', await orderbook2GetFacet.getTick());
        console.log(`---------------------------------------------------------------`);

        await orderbook2OrderFacet.order(1, 1750)
        console.log(`---------------------------------------------------------------`);
        console.log('Orderbook 2 Price: ', await orderbook2GetFacet.getPrice());
        console.log('Orderbook 2 Tick: ', await orderbook2GetFacet.getTick());
        console.log(`---------------------------------------------------------------`);

        await orderbook2CancelFacet.liquidation(30)
        console.log(`---------------------------------------------------------------`);
        console.log('Orderbook 2 Price: ', await orderbook2GetFacet.getPrice());
        console.log('Orderbook 2 Tick: ', await orderbook2GetFacet.getTick());
        console.log(`---------------------------------------------------------------`);
      });

    })
  });
});
