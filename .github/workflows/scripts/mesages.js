module.exports = ({prLink, diff}) => {
  const outputs = {};

  outputs.text = [
    "New commits were merged in rails-lts!",
    "Please review and deploy!",
    prLink
  ].join('\n');

  outputs.markdown = [
    "**New commits were merged in rails-lts!**",
    `[Please review and deploy!](${prLink})`,
    "```",
    diff,
    "```"
  ].join('\n');

  return outputs;
};
