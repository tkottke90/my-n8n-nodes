import type {
 IDataObject,
 IExecuteFunctions,
 INodeExecutionData,
 INodeType,
 INodeTypeDescription,
 } from 'n8n-workflow';
import { toSingleRecord } from '../../lib/n8n.utils';
import { NodeConnectionType } from 'n8n-workflow';

export class TdkMergeBranches implements INodeType {
 description: INodeTypeDescription = {
  displayName: 'Merge Branches',
  name: 'tdkMergeBranches',
  group: ['transform'],
  version: 1,
  description: 'Node to merge branches of a workflow together as a single record',
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
  const items = this.getInputData();
  
  const output: IDataObject = {};

  items.forEach(item => {
   Object.assign(output, item.json);
  })

  return toSingleRecord({
   ...output
  });
 }
}
