import {BuildSummaryResponse} from '../../models/build_summary';

// TODO: move all these mocks to common/ since they're being re-used.
export const mockBuildSummaryResponse_failure: BuildSummaryResponse = {
  number: 1,
  status: 'failure',
  duration: 1234,
  sha: 'cjsh4',
  link_to_sha: 'https://github.com/fastlane/ci/commit/1015c506762b1396a5d63fff6fe0f1de43c8de80',
  timestamp: '2018-04-04 16:11:58 -0700'
};

export const mockBuildSummaryResponse_success: BuildSummaryResponse = {
  number: 2,
  status: 'success',
  duration: 221234,
  sha: 'asdfshzdggfdhdfh4',
  link_to_sha: 'https://github.com/fastlane/ci/commit/1015c506762b1396a5d63fff6fe0f1de43c8de80',
  timestamp: '2018-04-04 16:11:58 -0700'
};
