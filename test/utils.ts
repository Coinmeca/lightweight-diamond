import { BaseContract, Contract } from "ethers";
import { ethers } from "hardhat";

export const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 }

export async function getSelectors(contract: any) {
    const selectors: any = [];
    for (const fragment of contract.interface.fragments) {
        if (fragment.type === 'function') {
            const selector = ethers.keccak256(ethers.toUtf8Bytes(fragment.format('sighash')));
            selectors.push(selector.slice(0, 10));
        }
    }
    selectors.contract = contract;
    selectors.remove = remove;
    selectors.get = get;
    return selectors;
}

export async function getSelector(func: any) {
    const abiInterface: any = new ethers.Interface([func])
    return abiInterface.getSighash(ethers.Fragment.from(func))
}

// 함수 고유 식별자 배열 받아서 -> 찾은다음에 제거
export async function remove(this: any, functionNames: string[]) {
    const selectors: any = this.filter((v: any) => {
        for (const functionName of functionNames) {
            if (v === this.contract.interface.getSighash(functionName)) {
                return false
            }
        }
        return true
    })
    selectors.contract = this.contract
    selectors.remove = this.remove
    selectors.get = this.get
    return selectors
}

export async function get(this: any, functionNames: string[]) {
    const selectors = this.filter((v: any) => {
        for (const functionName of functionNames) {
            if (v === this.contract.interface.getSighash(functionName)) {
                return true
            }
        }
        return false
    })
    selectors.contract = this.contract
    selectors.remove = this.remove
    selectors.get = this.get
    return selectors
}

export async function removeSelectors(selectors: any, signatures: any) {
    const iface: any = new ethers.Interface(signatures.map((v: string) => 'function ' + v))
    const removeSelectors = signatures.map((v: any) => iface.getSighash(v))
    selectors = selectors.filter((v: any) => !removeSelectors.includes(v))
    return selectors
}

export async function findAddressPositionInFacets(facetAddress: any, facets: any) {
    for (let i = 0; i < facets.length; i++) {
        if (facets[i].facetAddress === facetAddress) {
            return i
        }
    }
}
