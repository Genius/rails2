module.exports = async ({github, context}) => {
  const { repo, owner } = context.repo;

  const resultPullsList = await github.rest.pulls.list({
    owner,
    repo,
    state: 'open',
    head: '2-3-lts',
    base: '2-3-lts-for-genius',
  });
  const existingPr = resultPullsList.data[0];
  if (existingPr) {
    return existingPr;
  }

  const resultPullsCreate = await github.rest.pulls.create({
    owner,
    repo,
    title: '[Automated workflow] New Rails LTS commits',
    head: '2-3-lts',
    base: '2-3-lts-for-genius',
    body: [
      'This is an automated PR to keep track of Rails LTS changes',
      '',
      'To resolve conflicts keep in mind following points:',
      '- Keep using ** in keyword arguments instead of `ruby2_keywords`',
      '- Keep rack < 2.0, allowing rack 1.6',
      '- Make sure we won\'t use the deprecated `-i` option in `pg_dump`',
    ].join('\n')
  });
  const newPr = resultPullsCreate.data;

  github.rest.issues.addLabels({
    owner,
    repo,
    issue_number: newPr.number,
    labels: ['rails lts']
  });
  return newPr;
};
