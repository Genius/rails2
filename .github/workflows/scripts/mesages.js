module.exports = ({steps}) => {
  const outputs = {};

  outputs.text = [
    "New commits were merged in rails-lts!",
    "Please review and deploy!",
    steps.pr.outputs.result.html_url
  ].join('\n');

  outputs.markdown = [
    "**New commits were merged in rails-lts!**",
    `[Please review and deploy!](${steps.pr.outputs.result.html_url})`,
    "```",
    steps['git-diff'].outputs.pretty_diff,
    "```"
  ].join('\n');

  return outputs;
};
