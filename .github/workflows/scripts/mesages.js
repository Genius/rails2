module.exports = ({rawSteps}) => {
  const steps = JSON.parse(rawSteps);
  const output = {};

  output.text = [
    "New commits were merged in rails-lts!",
    "Please review and deploy!",
    steps.pr.outputs.result.html_url
  ].join('\n');

  output.markdown = [
    "**New commits were merged in rails-lts!**",
    `[Please review and deploy!](${steps.pr.outputs.result.html_url})`,
    "```",
    steps.git-diff.outputs.pretty_diff,
    "```"
  ].join('\n');

  return output;
};
