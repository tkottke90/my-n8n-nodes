import type {
  IExecuteFunctions,
  INodeExecutionData,
  INodeType,
  INodeTypeDescription
} from 'n8n-workflow';
import { toSingleRecord } from '../../lib/n8n.utils';
import { NodeConnectionType } from 'n8n-workflow';

export class TdkMergeBranches implements INodeType {
 description: INodeTypeDescription = {
  displayName: 'Merge Branches',
  icon: 'file:./TdkMergeBranches.svg',
  name: 'tdkMergeBranches',
  group: ['transform'],
  version: 1,
  description: 'Merges 2 json data sets together (similar to a Javascript object spread).  Keys in Input 2 will overwrite keys in Input 1.',
  defaults: {
   name: 'Merge Branches',
  },
  inputs: [NodeConnectionType.Main, NodeConnectionType.Main],
  outputs: [NodeConnectionType.Main],
  usableAsTool: true,
  properties: [],
 };

 // The function below is responsible for actually doing whatever this node
 // is supposed to do. In this case, we're just appending the `myString` property
 // with whatever the user has entered.
 // You can make async calls and use `await`.
 async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
  const sideA = this.getInputData(0)[0].json;
  const sideB = this.getInputData(1)[0].json;
  
  return toSingleRecord({
    ...sideA,
    ...sideB
  });
 }
}
