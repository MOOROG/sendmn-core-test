USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerAgreeDocumentTbl]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerAgreeDocumentTbl](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[PdfName] [varchar](150) NULL,
	[AgreePdfPAth] [nvarchar](150) NULL,
	[createBy] [nvarchar](50) NULL,
	[createDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[targetObj] [nvarchar](10) NULL,
 CONSTRAINT [PK_customerAgreeDocumentTbl] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
