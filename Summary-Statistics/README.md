# Summary statistics commands

Here are the commands used to obtain all the relevant statistics for this study:

## Average Mismatch Error

Average mismatch error was obtained by running:

```bash
while read -r filepath; do
    echo "File: $(basename "$filepath")";
    awk -F',' '
        NR > 1 {
            sum += $11;
            count++
        }
        END {
            if (count > 0)
                print "Average:", sum/count;
            else
                print "No data"
        }
    ' "$filepath";
done < bamconcordance-outputs.txt > AverageMismatches.txt
```

Where `bamconcordance-outputs.txt` is a file that looks like:

```
/path/to/bamconcordance/output1.csv
/path/to/bamconcordance/output2.csv
etc
```

## Average Homopolymer Insertion Error

Average homopolymer insertion error was obtained by running:

```bash
while read -r filepath; do
    echo "File: $(basename "$filepath")";
    awk -F',' '
        NR > 1 {
            sum += $12;
            count++
        }
        END {
            if (count > 0)
                print "Average:", sum/count;
            else
                print "No data"
        }
    ' "$filepath";
done < bamconcordance-outputs.txt > AverageHomopolymerInsertions.txt
```

## Average Non-Homopolymer Deletion Error

Average non-homopolymer deletion error was obtained by running:

```bash
while read -r filepath; do
    echo "File: $(basename "$filepath")";
    awk -F',' '
        NR > 1 {
            sum += $13;
            count++
        }
        END {
            if (count > 0)
                print "Average:", sum/count;
            else
                print "No data"
        }
    ' "$filepath";
done < bamconcordance-outputs.txt > AverageNonHomopolymerDeletions.txt
```

## Average Homopolymer Insertion Error

Average homopolymer insertion errors was obtained by running:

```bash
while read -r filepath; do
    echo "File: $(basename "$filepath")";
    awk -F',' '
        NR > 1 {
            sum += $14;
            count++
        }
        END {
            if (count > 0)
                print "Average:", sum/count;
            else
                print "No data"
        }
    ' "$filepath";
done < bamconcordance-outputs.txt > AverageHomopolymerInsertions.txt
```

## Average Homopolymer Deletion Error

Average homopolymer deletion error was obtained by running:

```bash
while read -r filepath; do
    echo "File: $(basename "$filepath")";
    awk -F',' '
        NR > 1 {
            sum += $15;
            count++
        }
        END {
            if (count > 0)
                print "Average:", sum/count;
            else
                print "No data"
        }
    ' "$filepath";
done < bamconcordance-outputs.txt > AverageNonHomopolymerDeletions.txt
```

## Merqury QV

Merqury QV values were obtained by running:

```bash
while read -r filepath; do
    echo "File: $(basename "$filepath")";
    awk '{ print "Merqury QV:", $4 }' "$filepath";
done < merqury-qv-file-paths.txt > MerquryQVs.txt
```

Where `merqury-qv-file-paths.txt` is a file that looks like:

```
/path/to/merqury/output1.qv
/path/to/merqury/output2.qv
etc
```

## Number of Reads

Read counts were obtained by running:

```bash
module load seqkit
while read -r filepath; do
    seqkit stats "$filepath"
done < all-reads.txt > ReadStats.txt
```

Where `all-reads.txt` is a file that looks like:

```
/path/to/reads1
/path/to/reads2
etc
```
