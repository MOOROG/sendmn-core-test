USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sendTransactionMaster]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sendTransactionMaster](
	[SEND_TRN_ID] [int] IDENTITY(1,1) NOT NULL,
	[SENDING_AGENT_NAME] [varchar](50) NOT NULL,
	[SENDING_AGENT_ID] [int] NOT NULL,
	[TRANSFER_AMT] [money] NOT NULL,
	[SERVICE_CHARGE] [money] NOT NULL,
	[COLLECT_AMT] [money] NOT NULL,
	[SENDER_NAME] [varchar](50) NOT NULL,
	[S_ADDRESS] [varchar](200) NOT NULL,
	[SCONTACT_NO] [varchar](20) NOT NULL,
	[SID_TYPE_id] [int] NOT NULL,
	[SID_NO] [varchar](30) NOT NULL,
	[SEMAIL] [varchar](100) NULL,
	[RECEIVER_NAME] [varchar](50) NOT NULL,
	[R_ADDRESS] [varchar](200) NOT NULL,
	[RCONTACT_NO] [varchar](20) NOT NULL,
	[RID_TYPE_ID] [int] NULL,
	[RID_NO] [varchar](30) NULL,
	[RELATIONSHIP] [varchar](50) NOT NULL,
	[PAYMENT_MODE] [int] NOT NULL,
	[RECEIVING_AGENT_ID] [int] NOT NULL,
	[RAGENT_AC] [varchar](25) NULL,
	[RAGENT_BRANCH_ID] [int] NULL,
	[REMARKS] [varchar](max) NOT NULL,
	[CREATED_BY] [varchar](30) NOT NULL,
	[CREATED_DATE] [datetime] NOT NULL,
	[APPROVED_BY] [varchar](50) NULL,
	[APPROVED_DATE] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
