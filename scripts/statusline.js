// 状态栏脚本：显示 工作目录名 | 模型名 | 上下文剩余百分比
let data = '';
process.stdin.on('data', (chunk) => { data += chunk; });
process.stdin.on('end', () => {
  try {
    const o = JSON.parse(data);
    const dir = (o.workspace && o.workspace.current_dir) || '';
    // 统一用正斜杠，取最后一段作为目录名
    const cwd = dir.replace(/\\/g, '/').split('/').filter(Boolean).pop() || dir;
    const model = (o.model && o.model.display_name) || '';
    const remaining = o.context_window && o.context_window.remaining_percentage;
    if (remaining != null) {
      console.log(cwd + ' | ' + model + ' | ctx: ' + remaining + '%');
    } else {
      console.log(cwd + ' | ' + model);
    }
  } catch (e) {
    console.log('');
  }
});
