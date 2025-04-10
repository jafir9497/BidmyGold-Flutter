const kycVerification = require("./admin/kycVerification");
const pawnbrokerVerification = require("./admin/pawnbrokerVerification");

exports.updateKycStatus = kycVerification.updateKycStatus;
exports.updatePawnbrokerStatus = pawnbrokerVerification.updatePawnbrokerStatus;
