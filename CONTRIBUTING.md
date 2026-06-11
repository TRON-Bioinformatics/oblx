## Contribute

Contributions are very welcome and acknowledged. Therefore, create a new issue
that describes the required contribution and steps. We will check if the feature
fits into the concept. If this is the case, create a merge request and we will
merge the code if everything works well.

You can contribute in many ways:


### Fix documentation

If you find any errors or inconsistencies in the [documentation](https://tron-bioinformatics.github.io/OBLX/), please create a
merge request with the necessary corrections. This helps ensure that the
documentation remains accurate and up-to-date.

### Implementation of further indices

We welcome every contribution of additional indices as this makes OBLX even more
helpful. Please also see the [developer guide](https://tron-bioinformatics.github.io/OBLX/developer_guide) for guidelines.

To add another index, create a rule in `build_indices.smk` that creates the
index and add the output file path to the function get_build_indices_output in
`common.smk`.

### Implementation of further resources

If more resource files are required to either generate a new index or for a
specific tool, just create a new rule in `pull_resources.smk` and add the output
file(s) in get_pull_resources_output in `common.smk`.

### Adapt tool versions

Adapting tool versions is more complicated and will only be done if there are
good reasons to do so. If you need another version of a tool index, consider
creating a new rule in `build_indices.smk` that creates the required index with
the specific version of the tool.
