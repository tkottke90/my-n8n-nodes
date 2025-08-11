# Node: Merge Branches 

One challenge I found with the default N8N Nodes was that if I wanted to breakup my workflows into multiple branches the process of merging them back together was a bit clunky.  Found I could do this with either a correctly configured `Merge` node set OR with a `Code` node but wanted to create a custom node that does the same.  I also found that when working with N8N I was not often working with multi-item arrays and so the `Merge` node was overkill for my use cases.

Having a lot of experience with Javascript, it is not uncommon to merge 2 objects together and so it was a bit of a oddity that this was not available out of the box. This node simply takes the first and second inputs and merges the items at the zero index together.  Keys in the second input will overwrite keys in the first input.

---

## Usage

![merge example](/docs/images//merge-example.png)

This node is simply used by adding it to your workflow and connecting the branches you want to merge together.  The node will then merge the 2 inputs together and pass the result on to the next node.

> [!important] 
> This node only merges the zero index of each input.  If you have multiple items in your input arrays, you will need to use a different strategy.  Also this will act like a Javascript object spread or `Object.assign` which means that any keys in the second input will overwrite keys in the first input.

