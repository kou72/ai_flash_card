// 実行時間のyyyyMMddhhmmssを日本時間で取得
export const getDate = () => {
  const JST_OFFSET = 9 * 60 * 60 * 1000; // 9時間をミリ秒で表現
  const date = new Date(Date.now() + JST_OFFSET);

  const formattedDate = `${date.getUTCFullYear()}${String(
    date.getUTCMonth() + 1
  ).padStart(2, "0")}${String(date.getUTCDate()).padStart(2, "0")}${String(
    date.getUTCHours()
  ).padStart(2, "0")}${String(date.getUTCMinutes()).padStart(2, "0")}${String(
    date.getUTCSeconds()
  ).padStart(2, "0")}`;

  return formattedDate;
};
