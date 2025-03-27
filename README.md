# StackSpot Workflow Action

This GitHub Action binds the GitHub execution ID to a StackSpot Workflow.

## Example usage

```yaml
  - name: StackSpot Workflow Execution Bind
    uses: stack-spot/stackspot-workflow-execution-bind@main
    with:
      execution-id: "${{ github.event.inputs.execution-id }}"
      realm: "${{ vars.REALM }}"
      client-id: "${{ secrets.CLIENT_ID }}"
      client-secret: "${{ secrets.CLIENT_SECRET }}"
```
