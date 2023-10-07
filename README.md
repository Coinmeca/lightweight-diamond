# Light-weight Diamond Pattern

[See example](https://github.com/l-Zetta-l/lightweight-diamond-example)

# Update Log

### 1.1.9

**Function Name**

- `setPermission` => `setAccess`
- `checkPermission` => `checkAccess`

### Installaion

**NPM**

```
npm install @coinmeca/lightweight-diamond -D
```

**Yarn**

```
yarn add @coinmeca/lightweight-diamond -D
```

## Overview

This project was created to make it easier to use the diamond pattern through abstract implementation and inheritance.

### Folder Structure

Functions are spread out from the one single contract as facets in the diamond pattern. Categorizing contracts with just types such as 'interfaces' or 'libraries' would make a project more complex. So in this case suggest to use like a grouping like a family according to their function's same point of features. This hierarchy and its folder structure follow:

```
─ contracts
  └─ services
     ├─ service1
     │  ├─ `Service.sol` : Diamond contract
     │  ├─ `IService.sol` : Interface that combine with all of facet's functions for diamond contract
     │  ├─ `Data.sol` : Data storage for diamond contract
     │  ├─ shared : Shared functions between facets
     │  │  ├─ `Modifers.sol` : Modifier functions for facets
     │  │  ├─ `Events.sol` : Events for facets
     │  │  └─ `Internals.sol` : Shared functions as internal for facets
     │  └─ facets : Facets
     │     ├─ `Facet1.sol`
     │     ├─ `Facet2.sol`
     │     └─ `Facet3.sol`
     │
     ├─ service2
     ：
```

`modules`: The `modules` folder is similar to `node_modules`. This is a folder that contains template contracts with ready-made functions that we need to refer to and use through importing. The light-weight version of the Diamond contract we use is located [here](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/modules/diamond/).

## Concept

This example was created to help implement diamond patterns easily. Also, if you want to provide clear addresses to separate the touchpoints with which users will interact, you can implement a diamond pattern that shares functionality but has different data storage.

In this example repository, facet management and state value management storage are used separately. Storage for diamond or facet management is created through `DiamondContractManger`, which is only used for adding and managing facets. The unique state value of a specific diamond is managed by [Data.sol](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/contracts/services/market/Data.sol).

-   `DiamondContract` : It is an abstracted contract with a constructor and fallback and receive functions to use the Diamond pattern. It has a separate `DiamondContractManger`.
-   `DiamondContractManager`: It has storage just for facet management along with the function to manage facets and owners included in the contract.
-   `DiamondFacade` : This is an abstraction contract provided for the creation of a diamond contract. It does not hold any storage or facets itself and acts as a relay that only holds 'fallback'.

### Inheriting and Implementation

This implementation simplifies building the diamond pattern through contract inheritance, as shown below:

```
import {DiamondContract} from "@coinmeca/lightweight-diamond/DiamondContract.sol";

contract Service is DiamondContract
```

### Storage dividing, classifying, and identifying for facet managements

Lightweight Diamond Template's diamondCut arguments is little bit with original standard codes. In this template, we need to use the key in deploy(test) code. This helps make facet management richer and more versatile.

As with the existing diamond pattern, if one diamond has a function for that diamond only, simply write it as an array of one length, with one struct present:

```
const Diamonds = [
  {
    key: 'diamond.only',
    data: [
      // Market facets
      'market/facets/Create.sol:Create',
      'market/facets/Markets.sol:Markets'
    ]
  }
];
```

Or, if you want to manage the functions of multiple facets at one diamond and use them publicly without special access rights, you can use the following structure:

```
const Diamonds = [
  {
    key: 'one.diamond',
    data: [
      // Market facets
      'market/facets/Create.sol:Create',
      'market/facets/Markets.sol:Makrets',

      // Orderbook facets
      'orderbook/facets/Order.sol:Order',
      'orderbook/facets/Cancel.sol:Cancel',
      'orderbook/facets/Get.sol:Get',

      // OrderNFT facets
      'orderbook/nft/facets/Mint.sol:Mint',
      'orderbook/nft/facets/Burn.sol:Burn',
      'orderbook/nft/facets/Transfer.sol:Transfer'
    ]
  }
];
```

Or maybe you want to use something a little more complicated: The example below manages all the facets in one diamond, but separates the keys so that they can only be accessed and used by the diamond or facade that matches that particular key:

```
const Diamonds = [
  {
    key: 'market',
    data: [
      // Market facets
      'market/facets/Create.sol:Create',
      'market/facets/Markets.sol:Makrets',
    ]
  },
  {
    key: 'orderbook',
    data: [
      // Orderbook facets
      'orderbook/facets/Order.sol:Order',
      'orderbook/facets/Cancel.sol:Cancel',
      'orderbook/facets/Get.sol:Get',
    ]
  },
  {
    key: 'nft',
    data: [
      // OrderNFT facets
      'orderbook/nft/facets/Mint.sol:Mint',
      'orderbook/nft/facets/Burn.sol:Burn',
      'orderbook/nft/facets/Transfer.sol:Transfer'
    ]
  }
];
```

### PrivateKey for Storage

As mentioned above, the defined key is used by each diamond or facade to find the slot position in the diamond storage where the facets and functions it can use are stored. Therefore, depending on the contract type, even if the address of the contract is different, it can be grouped into one common type through the key.

```
─ Market Diamond Slot ─
slot position: 0x1a2b3  = keccak256('market'):     Market facets
slot position: 0x4c5d6  = keccak256('orderbook'):  Orderbook facets
slot position: 0x7e8f9  = keccak256('orderNFT'):   Order NFT facets
```

In the constructor, just simply set the service contract's key (slot position) for data storage.

```
contract Service is DiamondContract{
    constructor(
        IDiamond.Cut[] memory _diamondCut,
        IDiamond.Args memory _args
    ) DiamondContract("market", _diamondCut, _args) {}
}
```

If it facade, can be used like this. facada need the parent diamond's address for the finding there facets, because of they doens't own their facets.

```
contract Service is DiamondFacade{
    constructor(
        address _parentDiamond
    ) DiamondFacade("orderbook", _parentDiamond) {}
}
```

Through the key defined above, we can divide storage and identify position, and figure values, then use this. This can also be used for access control purposes. All the facets were stored in one diamond, but even the diamond self cannot access the child's (facade) storage position because they have different keys to each other.

```
─ Market Diamond ─────────────┬──┬──┐
  └─ DiamondContractManager   │  │  │
    └─ Market Facets　   ◀────┘  │  │
    └─ Orderbook Facets  ◀── ✕ ──┘  │
    └─ OrderNFT Facets   ◀── ✕ ─────┘
```

```
─ Market Diamond ──────────────┐
  └─ DiamondContractManager    │
    └─ Market Facets　   ◀─────┘
    └─ Orderbook Facets  ◀──┐
    └─ OrderNFT Facets   ◀──┼──┐
                            │  │
─ Orderbook Facade  ────────┘  │
─ Order NFT Facade  ───────────┘

```

Possible to divide storage and access this via a one diamond, But also can make another diamond as a sharing point for common functions that be working in each clone contracts(facade).

```
─ Market Diamond
  └─ DiamondContractManager
     └─ Market Facets ─┐
                       │
┌─ Contract Factory ───┘
▼
─ Orderbook 1
  │ ├─ Local Data Storage
  │ └─ Orderbook Functions (Fallback) ──┐
  │                                     │
─ Orderbook 2                           │
  │ ├─ Local Data Storage               │
  │ └─ Orderbook Functions (Fallback)  ─┤
　：                                     │
                                        │
─ Orderbook Function Store              │
└─ DiamondContractManager               │
    └─ Orderbook Facets  ◀──────────────┘

```

Can use this for various types or with any purpose that want to use via assemble modules or according to usage.

### Deploy and Prework

There's one important thing for usage and have to remember is the prework in writing the deployment script. It is crucial to ensure that the keys used to divide and classify facets are consistent in both the deploy (test) code and the contract's constructor.

```
[
  { key: 'market', data: [ [Object], [Object] ] },
  { key: 'orderbook', data: [ [Object], [Object], [Object] ] },
  { key: 'nft', data: [ [Object], [Object], [Object] ] }
]
```

```
contract Market is DiamondContract{
    constructor(
      IDiamond.Cut[] memory _diamondCut, IDiamond.Args memory _args
    ) DiamondContract("market", _diamondCut, _args) {}
}

contract Orderbook is DiamondFacade{
    constructor(address _parentDiamond
    ) DiamondFacade("orderbook", _parentDiamond) {}
}

contract OrderNFT is DiamondFacade{
    constructor(address _parentDiamond
    ) DiamondFacade("nft", _parentDiamond) {}
}
```

Failure to do so may result in the facets being stored in the wrong position of the slot or the contract attempting to locate the facet addresses in the wrong position.

### Interfaces

As mentioned, Facade only acts as an endpoint to help connect in the middle, and since all facet data is managed by Diamond, the interfaces of child facades cannot be allow in each their facade directly. Therefore, if you want to manage the interface according to the type of each child facade, you must interact directly with the parent diamond. You can call `setInterface(bytes32 _key, bytes4 _interface, bool _state)` directly, but if you want to batch process it directly in the constructor, you can use it as follows.

```
constructor(
    IDiamond.Cut[] memory _diamondCut,
    IDiamond.Args memory _args
) DiamondContract("market", _diamondCut, _args) {
    setInterface(
        keccak256("market"),
        type(IMarket).interfaceId,
        true
    );

    setInterface(
        keccak256("orderbook"),
        type(IOrderbook).interfaceId,
        true
    );

    setInterface(
        keccak256("nft"),
        type(INFT).interfaceId,
        true
    );
}
```

### Diamond Factory

This repository is an example to address the following needs:

-   In order for users to clearly distinguish and interact with a specific orderbook among orderbooks for various token pairs, a different address is required for each orderbook as an access point.
-   Each orderbook must have its own data storage and store real-time prices and orders in different storage, but share functionality.

And also our orderbook also can mint some NFTs that are similar to LP tokens, and which must be issued to separate addresses. The NFT will use the same address as the orderbook for pair identification.

For this purpose, this is an example of factory a diamond contract called an orderbook.

`Market.sol (Diamond)` : A market contract serves several functions for the market and includes common orderbook facets.
`Orderbook.sol (Facade)` : It is a contract that does not itself have a facet for implementing any functionality. The facade only has the address of the parent diamond contract, and the parent holds the facade's facet instead.

Therefore, facades can be created infinitely, each with its own storage. However, since all of the facades' functions are managed by the parent diamond, multiple diamond functions can be updated and managed at once.

```
─ Market.sol (Diamond)
  ├─ Data.sol (Local Data Storage for Market)
  │  └─ Local values for market contract only
  │
  └─ DiamondContractManager (Data Storage for Facets)
     ├─ Market facets
     └─ Orderbook facets  ◀───────────────────────────┐
                                                      │
─ Orderbook 1 (Diamond Facade) ───────────────────────┤
  │ └─ Data.sol (Local Data Storage for Orderbook 1)  │
  │    └─ Local values for orderbook 1 only           │
  │                                                   │
─ Orderbook 2 (Diamond Facade) ───────────────────────┘
  │ └─ Data.sol (Local Data Storage for Orderbook 2)
  │    └─ Local values for orderbook 2 only
　：
```

### Internal

The functions defined in `Internals.sol` are internal and cannot be accessed from outside the blockchain, but also define functions shared by functions of different Facets. You can find an example in [Internals.sol](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/contracts/services/orderbook/shared/Internals.sol).

```
import 'Data.sol';

library Internals {
    using Data for Data.Storage;
    using Internals for Data.Storage;

    function internalFunction1 (Data.Storage storage $, uint _value) internal {
      $.value = _value
    }

    function internalFunction2 (Data.Storage storage $, uint _value) internal view returns(uint) {
      return $.value;
    }
}
```

A use case for internal functions that need to be shared between facets can be found in [Internals.sol](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/contracts/services/orderbook/shared/Internals.sol), [Order.sol](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/contracts/services/orderbook/facets/Order.sol) and [Cancel.sol](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/contracts/services/orderbook/facets/Cancel.sol).

```
import {Data} from "../Data.sol";

library Internals {
  using Data for Data.Storage;
  using Internals for Data.Storage;

  function internalFunction (Storage storage $, uint _value) internal {
    $.myValue = _value
  }
}
```

```
import {Internals} from '../shared/Internals.sol'

contract FacetA {
    using Internals for Data.Storage;

    function functionFacetA (uint _value) public {
      $.internalFunction(_value);
    }
}

contract FacetB{
    using Internals for Data.Storage;

    function functionFacetB (uint _value) public {
      $.internalFunction(_value);
    }
}
```

For the public functions, you can use them by declaring them in an interface and referencing them.

```
interface IMarket {
  function facetAfunction() external;

  function facetBfunction() external;
}

contract MarketFacetA{
  funtionc facetAfunction() public {
    IMarket(address(this)).facetBfunction();
  }
}

contract MarketFacetB{
  funtionc facetBfunction() public {
    IMarket(address(this)).facetAfunction();
  }
}
```

### Data Storage

Storage that manages facets is automatically created through `DiamondContractManger` by inheriting `DiamondContract`. Separately from this, variables for state management targeting only specific services related to the business logic of the contract must form a separate [Data.sol](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/contracts/services/orderbook/Data.sol) contract.

```
library Data {
  Storage {
    bool myValue1;
    uint myValue2;
    address myValue3;
  }

  function load() internal pure returns (Storage storage $) {
      bytes32 __ = key;
      assembly {
          $.slot := __
      }
  }
}
```

If you want to reference data storage in facets, they can be used in the following ways:

```
import {Data} './Data.sol';

contract Facet{

  function myFunction() public returns (uint) {
    Data.Storage storage $ = Data.load();
    return $.myValue;
  }

  ...
}
```

Or, for easier use, you can more conveniently access storage from all facets with a single declaration in the [Modifiers.sol](https://github.com/l-Zetta-l/lightweight-diamond-example/blob/main/contracts/services/orderbook/shared/Modifiers.sol) contract that all facet contracts inherit.

```
import {Data} './Data.sol';

contract Modifiers {
  using Data for Data.Storage;
  Data.Storage internal $;
}

contract FacetA is Modifiers{
  function Function1 () public {
    $.myValue + 1;
  }
}

contract FacetB is Modifiers{
  function Function2 () public {
    $.myValue * 4;
  }
}
...

```

## Requirements

-   [Node.js 20+](https://nodejs.org)
-   [Yarn](https://yarnpkg.com/) _(NOTE: `npm` and `pnpm` can also be used)_

## License

MIT - see [LICSENSE](LICENSE)
