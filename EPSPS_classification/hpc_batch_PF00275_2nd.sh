#!/bin/bash
#SBATCH --job-name=epsps_PF00275_
#SBATCH --output=job_PF00275_%j.out
#SBATCH --error=job_PF00275_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --partition=cpu8358
#SBATCH --qos=cpudebug

# 加载正确的模块版本
module load prodigal/2.6.3-gcc-8.5.0-pzudqi
module load hmmer/3.3.2-gcc-8.5.0-icp26xy
module load python/3.9.16-gcc-8.5.0-izf3oyf
module load py-numpy/1.24.3-gcc-8.5.0-znneimt
module load py-biopython/1.81-gcc-8.5.0-gby2hxv

DATA_LINK="/gpfs/work/bio/qiulinzhang24/SuzhouBeeData2nd"
OUTPUT_DIR="batch_results_PF00275_wildbee2nd"
mkdir -p "$OUTPUT_DIR"

for sample_num in {006..016}; do
    CONTIGS_FILE="$DATA_LINK/230703G${sample_num}.contigs.fa"
    SAMPLE_OUT="$OUTPUT_DIR/230703G${sample_num}"
    mkdir -p "$SAMPLE_OUT"

    echo "===== 处理样本 230703G${sample_num} ====="

    # Prodigal预测蛋白质
    prodigal -i "$CONTIGS_FILE" \
             -a "$SAMPLE_OUT/proteins.faa" \
             -p meta \
             -o "$SAMPLE_OUT/prodigal.gff" \
             -f gff

    # HMMsearch搜索PF00275
    hmmsearch --cut_nc \
              --tblout "$SAMPLE_OUT/hmm_PF00275.txt" \
              PF00275.hmm \
              "$SAMPLE_OUT/proteins.faa"

    # 提取命中ID
    grep -v '^#' "$SAMPLE_OUT/hmm_PF00275.txt" | cut -f1 | sort | uniq > "$SAMPLE_OUT/hit_ids_PF00275.txt"

    # 修正ID后缀
    sed 's/$/_1/' "$SAMPLE_OUT/hit_ids_PF00275.txt" > "$SAMPLE_OUT/corrected_ids_PF00275.txt"

    # 提取目标序列
    python batch_results_PF00275_wildbee2nd/extract_seqs.py \
           "$SAMPLE_OUT/proteins.faa" \
           "$SAMPLE_OUT/corrected_ids_PF00275.txt" \
           "$SAMPLE_OUT/matched_PF00275.faa"


    echo "===== 样本 230703G${sample_num} 处理完成 ====="
done

echo "🎉 所有样本分析完成！结果在 $OUTPUT_DIR"
