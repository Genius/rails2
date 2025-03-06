module.exports = async ({github, context, core}) => {
  core.info('Branches compared Genius/rails2/2-3-lts and makandra/rails/2-3-lts');
  core.info('No changes detected in railslts-version/lib/railslts-version.rb');
  core.info('Canceling workflow');

  github.rest.actions.cancelWorkflowRun({
    owner: context.repo.owner,
    repo: context.repo.repo,
    run_id: context.runId
  });

  const delay = ms => new Promise(res => setTimeout(res, ms));
  core.info('Waiting for workflow to cancel...');
  await delay(5000);
  throw "Timeout: Workflow was supposed to be cancelled"
};
