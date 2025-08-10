import type { IDataObject, INodeExecutionData } from 'n8n-workflow';

export function toSingleRecord(input: IDataObject): INodeExecutionData[][] {
  return [
    [ { json: input } ]
  ];
}