USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ratingDetail]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ratingDetail](
	[detailId] [int] IDENTITY(1,1) NOT NULL,
	[assessementId] [int] NOT NULL,
	[criteriaId] [int] NOT NULL,
	[score] [money] NOT NULL,
	[remarks] [varchar](2500) NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
 CONSTRAINT [PK_ratingDetail_1] PRIMARY KEY CLUSTERED 
(
	[detailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
