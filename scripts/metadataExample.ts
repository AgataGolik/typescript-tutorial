import { StoryClient, StoryConfig, IpMetadata, PIL_TYPE } from '@story-protocol/core-sdk'
import { http } from 'viem'
import { privateKeyToAccount, Address, Account } from 'viem/accounts'
import { uploadJSONToIPFS } from './utils/uploadToIpfs'
import { createHash } from 'crypto';

const main = async function () {
  try {
      const privateKey: Address = `0x${process.env.WALLET_PRIVATE_KEY}`;
      const account: Account = privateKeyToAccount(privateKey);
      
      const config: StoryConfig = {  
        account: account,  
        transport: http(process.env.RPC_PROVIDER_URL),  
        chainId: 'iliad',  
      };  
      const client = StoryClient.newClient(config);

      const ipMetadata: IpMetadata = client.ipAsset.generateIpMetadata({
        title: 'P2E Sonny',
        description: 'Sony is the best',
        watermarkImg: 'https://picsum.photos/200',
        attributes: [
          {
            key: 'Rarity',
            value: 'Legendary',
          },
        ],
      });

      const nftMetadata = {
        name: 'Test NFT',
        description: 'The best nft ever',
        image: 'https://picsum.photos/200',
      };

      const ipIpfsHash = await uploadJSONToIPFS(ipMetadata);
      const ipHash = createHash('sha256').update(ipIpfsHash).digest('hex');

      const nftIpfsHash = await uploadJSONToIPFS(nftMetadata);
      const nftHash = createHash('sha256').update(nftIpfsHash).digest('hex');

      const response = await client.ipAsset.mintAndRegisterIpAssetWithPilTerms({
          nftContract: process.env.NFT_CONTRACT_ADDRESS as Address,
          pilType: PIL_TYPE.NON_COMMERCIAL_REMIX,
          ipMetadata: {
              ipMetadataURI: `https://ipfs.io/ipfs/${ipIpfsHash}`,
              ipMetadataHash: `0x${ipHash}`,
              nftMetadataURI: `https://ipfs.io/ipfs/${nftIpfsHash}`,
              nftMetadataHash: `0x${nftHash}`,
          },
          txOptions: { waitForTransaction: true }
      });

      console.log(`Root IPA created at transaction hash ${response.txHash}, IPA ID: ${response.ipId}`);
      console.log(`View on the explorer: https://explorer.story.foundation/ipa/${response.ipId}`);
  } catch (error) {
      console.error('Error occurred:', error);
  }
}

main();
