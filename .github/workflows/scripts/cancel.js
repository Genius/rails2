module.exports = async ({github, core}) => {
  core.info('Branches compared Genius/rails2/2-3-lts and makandra/rails/2-3-lts');
  core.info('No changes detected in railslts-version/lib/railslts-version.rb');
  core.info('Canceling workflow');

  github.rest.actions.cancelWorkflowRun({
    owner: context.repo.owner,
    repo: context.repo.repo,
    run_id: context.runId
  });

  const delay = ms => new Promise(res => setTimeout(res, ms));
  while (true) {
    core.info('Waiting for workflow to cancel...');
    await delay(5000);
  }
};
