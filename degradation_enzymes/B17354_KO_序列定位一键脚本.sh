#!/bin/bash
# ===================== 固定配置（无需修改）=====================
# 1. 你的16个目标KO ID
TARGET_KO=(
    "K03430" "K05306" "K10713" "K01938" "K00219"
    "K02041" "K02044" "K02042" "K06166" "K24968"
    "K06164" "K06155" "K06163" "K01637" "K01638" "K00301"
)
# 2. 你要查询的单个细菌编号
TARGET_BACTERIA=(
    "B17354"
)
# 3. .ann文件的基础路径
ANN_BASE_PATH="/gpfs/work/bio/yiranwang2103/Wildbee/kofamscan/result/"
# 4. 最终结果输出文件
FINAL_RESULT="B17354_KO_对应序列ID结果.txt"

# ===================== 脚本核心逻辑（无需修改）=====================
# 清空旧结果，生成表头（让结果更清晰）
echo -e "细菌编号\tKO ID（酶）\t对应的k71序列ID" > ${FINAL_RESULT}

echo "🔍 开始一站式处理：筛选KO + 定位序列..."
echo -e "-------------------------\n"

# 遍历目标细菌
for bacteria_id in "${TARGET_BACTERIA[@]}"; do
    annfile="${ANN_BASE_PATH}${bacteria_id}.kofam.ann"
    echo "正在处理：${bacteria_id}"

    # 检查ann文件是否存在
    if [ ! -f "${annfile}" ]; then
        echo "⚠️  ${bacteria_id} 的.ann文件不存在，脚本退出！"
        exit 1
    fi

    # 遍历每个目标KO ID
    for ko_id in "${TARGET_KO[@]}"; do
        # 查找该KO对应的行，提取序列ID
        contig_line=$(grep "${ko_id}" "${annfile}")
        if [ -n "${contig_line}" ]; then
            # 提取第一列（k71序列ID）
            contig_id=$(echo "${contig_line}" | awk '{print $1}')
            # 写入结果文件
            echo -e "${bacteria_id}\t${ko_id}\t${contig_id}" >> ${FINAL_RESULT}
            echo "  ✅ ${bacteria_id} - ${ko_id} → 对应序列：${contig_id}"
        fi
    done
done

# ===================== 运行完成提示 =====================
echo -e "\n✅ 一站式处理完成！✅"
echo "📄 最终结果文件：${FINAL_RESULT}"
echo "🔍 快速查看结果的指令：cat ${FINAL_RESULT}"
