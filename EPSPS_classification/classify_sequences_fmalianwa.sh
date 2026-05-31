#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --partition=cpu8358
#SBATCH --qos=cpudebug
#SBATCH --output=sequence_classification_fmalianwa.out
#SBATCH --error=sequence_classification_fmalianwa.err

# 加载Python环境（根据HPC实际环境调整，若无特殊环境可注释）
module load python/3.8.10
module load biopython/1.79

# Python分析代码
python3 << EOF
from Bio import SeqIO
import sys

# 最新标志氨基酸位点定义（删除Class III，仅保留Iα、Iβ、II、IV，位点全量更新）
class_marker_sites = {
    "Class I α": {
        332:"S",333:"K",334:"S",338:"R",361:"D",412:"G",413:"T",416:"R",442:"R",443:"P",
        468:"P",499:"S",500:"Q",534:"T",576:"E",578:"D",609:"Q",701:"E",704:"R",716:"G",
        766:"D",767:"H",768:"R",794:"K",797:"P"  # 25个位点（逐分号计数）
    },
    "Class I β": {
        332:"S",333:"K",338:"R",361:"D",442:"R",443:"P",499:"S",500:"Q",534:"T",578:"D",
        673:"D",700:"K",701:"E",704:"R",716:"G",766:"D",767:"H",768:"R"  # 18个位点（逐分号计数）
    },
    "Class II": {
        332:"S",333:"K",334:"S",337:"H",338:"R",361:"D",410:"N",416:"R",420:"G",435:"G",
        436:"D",442:"R",443:"P",446:"R",450:"P",451:"L",499:"S",500:"A",501:"Q",503:"K",
        531:"R",535:"E",576:"P",578:"D",580:"S",606:"N",609:"R",673:"D",674:"E",696:"E",
        700:"K",701:"E",704:"R",766:"D",767:"H",768:"R",795:"S",797:"P"  # 38个位点（逐分号计数）
    },
    "Class IV": {
        336:"T",337:"A",338:"R",339:"A",340:"L",363:"E",364:"G",365:"F",366:"A",367:"E",
        368:"G",411:"G",412:"A",413:"T",414:"T",415:"A",416:"R",417:"F",418:"L",419:"P",
        420:"T",421:"L",422:"A",423:"A",424:"A",433:"F",434:"D",435:"A",436:"S"  # 29个位点（逐分号计数）
    }
}

# 输入文件路径（用户指定路径）
input_file = "/gpfs/work/bio/qiulinzhang24/Xylocopa fenestrata_马连洼街道.mas.fas"
# 输出文件路径
output_file = "sequence_classification_results_fmalianwa.tsv"

# 打开输出文件写入表头（无Class III列）
with open(output_file, "w") as f_out:
    header = "Sequence_ID\tClass_I_α_Score\tClass_I_α_Percent\tClass_I_β_Score\tClass_I_β_Percent\tClass_II_Score\tClass_II_Percent\tClass_IV_Score\tClass_IV_Percent\n"
    f_out.write(header)

    # 遍历fas文件中的每个序列
    for record in SeqIO.parse(input_file, "fasta"):
        seq_id = record.id
        seq = str(record.seq)
        results = [seq_id]

        # 对每个分类计算得分和百分比
        for class_name, sites in class_marker_sites.items():
            total_sites = len(sites)
            match_count = 0

            # 检查每个标志位点是否匹配（序列索引从0开始，位点编号从1开始）
            for pos, aa in sites.items():
                if pos <= len(seq):  # 确保位点在序列长度范围内
                    seq_aa = seq[pos-1]
                    if seq_aa == aa:
                        match_count += 1

            # 计算百分比（保留2位小数）
            percent = (match_count / total_sites) * 100 if total_sites > 0 else 0.0
            results.extend([str(match_count), f"{percent:.2f}"])

        # 写入当前序列结果
        f_out.write("\t".join(results) + "\n")

print(f"分析完成！结果已保存至 {output_file}")
EOF

echo "HPC任务执行完毕"

