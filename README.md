# proseg-workflow
Basic nextflow pipeline to run [Proseg](https://github.com/dcjones/proseg) on a single sample

## Configuration
Pipeline parameters can be specified in `nextflow.config`

Key parameters include:
* `platform` - `xenium`, `cosmx`, or `merfish`
* `outputDir` - where to store the output files
* `inputDir` - directory with the input file(s)
* `transcriptsFile` - filename in `inputDir` with transcript info. For Xenium this is `transcripts.csv.gz`
* `enforce_connectivity` - prevent cells from having disconnected voxels
* `ignore_z_coord` - run in 2D mode


## Install
Make sure [Nextflow](https://github.com/nextflow-io/nextflow) and [Proseg](https://github.com/dcjones/proseg) are installed.

### Docker
A [docker container](https://hub.docker.com/repository/docker/tbencomo/proseg/general) with Proseg is provided easy deployment

To run the pipeline with docker:
```
nextflow run main.nf -with-docker [docker env name]
```

## Execution
This workflow can be run on [Cirro](https://cirro.bio/)
