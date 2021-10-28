base = ARGV[0].split(",")
score = []
base.each do |value|
  if value == "X"
    score << 10
    score << 0
  else
    score << value.to_i
  end
end

frames = []
frame_count = 1
MAX_FRAME_COUNT = 10

while frame_count <= MAX_FRAME_COUNT
  if frame_count == MAX_FRAME_COUNT
    frames << score.slice((frame_count - 1) * 2..-1)
    break
  else
    frames << score.slice((frame_count - 1) * 2, 2)
    frame_count += 1
  end
end

p frames

# フレームの計算
# ストライクでもスペアでもない：ただの足し算
# スペア：スペアのフレームは10と次のフレームの1投目を足した数
# ストライク：10と次の次の投球までを足した数
total_points = 0
frames.each_with_index do |frame, index|
  # 最終フレームは単なる足し算
  if index == frames.size - 1
    total_points += frame.sum
    p total_points
    break
  # ストライクの場合は2つ先の投球まで足す
  elsif frame[0] == 10
    # 最初の投球の次の投球もストライクの場合
    if frames[index + 1][0] == 10
      total_points += frame.sum
      total_points += frames[index + 1][0]
      total_points += index + 1 == frames.size - 1 ? frames[index + 1][2] : frames[index + 2][0]
    else 
      total_points += frame.sum
      total_points += frames[index + 1][0]
      total_points += frames[index + 1][1]
    end
    p total_points
  # スペアの場合は次の投球を足す
  elsif frame[0] != 10 && frame.sum == 10
    total_points += frame.sum
    total_points += frames[index + 1][0]
    p "next_frame#{frames[index + 1][0]}"
    p total_points
  # それ以外の場合は単に足すだけ
  else
    total_points += frame.sum
    p total_points
  end
end

p total_points