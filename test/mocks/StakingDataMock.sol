// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract StakingDataMock {
    bytes constant pubKey =
        hex"92e48e3c4934c2b74ac151c1128369a33df4686533f50318eb4766a4895bd57ed9c3c14e4a2d92a55bcf7bd1fc9139e4";

    bytes constant withdrawal_credentials =
        hex"0017a025aec8ebcdb76913a4378a141408282430ebe58533604df7fc703b8946";

    bytes constant signature =
        hex"b7d6e13498d43bd9b1c4d6f759fcf1c1397a6626dca0c03a97cbe8345e45807f31292255dcfd5df7d1e333deba562bd408bbbb38a44bc201e9e12ce53c769153dffbb1cd7d59a4a40bea454dc49617f85c5f49f83a8bc3bbaae6d04a57b2aeb9";

    bytes32 constant deposit_data_root =
        hex"5e24800ee2656cc49c507844e5e6706c0cfca4c2312b4d13458851cf09f63b87";

    uint32[] operatorIds;
    bytes[] sharesPublicKeys;
    bytes[] sharesEncrypted;

    constructor() {
        operatorIds.push(1);
        operatorIds.push(2);
        operatorIds.push(42);
        operatorIds.push(127);

        bytes[] memory spk = new bytes[](4);

        spk[
            0
        ] = hex"937e3c247fa0bcab6bf7645443caea72519ce3f5c0230311511306248bc790ae9d7bb744b9b00085aab256723d3fae6d";
        spk[
            1
        ] = hex"aafde4020b642a53d824332386ef807ea4709ac765ab8baccfa180c9d4a5f498b66b499e4591879959cf0c6832c3a0fb";
        spk[
            2
        ] = hex"8d34bd7df7a13a2669d6f5a059e3e41040988bbfed146556989cacb927c528e0bdf3a807c36b1fb55f7f553cec7d51ba";
        spk[
            3
        ] = hex"aaeca38f14efbf5d7d4b153e8450bba62dd94b23ee5ea667b83f6a5e04ec3525103e03f261776e51b90116abaeeed48e";

        sharesPublicKeys = spk;

        bytes[] memory se = new bytes[](4);

        se[0] = bytes(
            "PTRmlQ2XQMXNrClQEErKrHk0qpIkAsrmgvZaIrmtd+QjDzKexA4vWqkDOl+vPwxgpJEjqEdZK0wlv1S4uRN/5DQFnh5mf/CwP6Up6AJpO56wY7l7q0sh7FL5ujcVsWfBDr3GN4XBMoBE4cIfhDQEBKyVnicw7UEHD2OYU/2KRK9ZU1j4Cl0qMXaKVmz/nX/T1Cu74zq8D61X0HgJigWEDlDUALcv36ChPOJCM0amBz61aUTAp/zD56HTqRE2UrL6txFyZ5VzRFEKUybKVRLOK/jnC8AdG5j3JUoxG8+m4wq+xPUXTv2dg9UZJH0JGMMB2JfYJ8DrnGABXsjJygObVg=="
        );
        se[1] = bytes(
            "zTzZ/hBNhor5Ij8/YrrkCWSoEkKmc4umnP9VPfovztnB1dQojMheaJoyscJohE9oA6yRh2kFRLz95q/a/WgmJRSbq74GAeQprXT27L3AZwgkpm/wKj4sawl1DK2kYF4uBvUXTh/70Wb2qY/CB77jV6d85BfJk/mvqQdqeJAqPOAuDki7bDDzWSBIQEaWcTMo1VUSPUZqMkCnBEHLyUgjGtNFm8uKtZkAjEOGjU+zIpRgiPTur6qThTp7LHhSVu7+Ef+r7uqpciM1goi1+jtY2efi//YgUUzlgEB6h2s2ajAUXmqKpc0EbChxWMkz34S+WDfXP/NCLO9wpIZC28Frqg=="
        );
        se[2] = bytes(
            "ZZDvaB4IveNEKbX0E9Yk3kkLvq8imFfudKhRq19FN47zUeX7x+NQMbsM9oztZDw0xFSUqJlEKEtOiEGpeh0XbDF+jG2CcNFxXwy6z4ZFbS0JzFobskwDzjdvmGot0OpeO/gU4xiDPG8AWccVta/xt5OsUh+BmQU2xAetqxgWzNrEfBtVgN3Da94GR6Aa8xF2J/fVn1XcVqle25m4ZXwX45Qv7gE6mzxn2BK42crFnzp6OfV2cIph4yaT8q6kMHnbZ71nUFbT/+DGI7zYnsL2vPeHl5enZ4Rq+nhPBaEqILg35yIUXU2w6+jaEYN/K8bT7+wKLdVp1/djYbkMrRDFXg=="
        );
        se[3] = bytes(
            "GnB9y9tcuomoCnOLDPx14reXAgJwg/CXf05BY1UlrCNHbc+AZ3pXF9lvCrwuPEUPKlJIuqwWLPCjKhmv7FJclIgSmNr7N2jbQJhwzZutu6xQhuwxgOL795Ww2R8XCYwsqNeDEbWdZA0BkA+3OU+wrI4mMyRHLC9lNJc+nvtqtl9Gw5IH5fzsGs5QJ1G4Rm2nNIWyzKAcfclVSIpvmHb4d23jFlUCsY7cttCUdEWr28JYxkGLF1kWkAJVyAUxSUucGgKpdlp1GWMYN8EfkYHzM4ObqCAbUX5B4DK1rQE/ILjgikyVJ8x8gcF4Fqkz1J1xPA3t+5r1F22QvwOdNHqhHA=="
        );

        sharesEncrypted = se;
    }
}
