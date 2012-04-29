dump=$1

`extract.sh /cvg/compute_videogame $dump`
`extract_name.sh`
`associate.sh`
`create.sh`
`extract.sh`
`extract_foreign_language.sh`
